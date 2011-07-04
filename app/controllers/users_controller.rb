# encoding: utf-8
# Редакторы сайта
class UsersController < ApplicationController
  # Запрещаем все действия посторонним посетителям.
  # Кроме просмотра списка редакторов и выбора способа входа для новых
  # пользователей (которые пока ещё не могут войти).
  before_filter :authenticate_user!, except: [:index, :auth]
  
  # Загружаем пользователя из БД для действий, где он нужен
  before_filter :load_user, only: [:update, :destroy, :request_auth, :auth]
  
  # Список всех редакторов
  def index
    @users = User.order_by(name: :asc)
  end
  
  # Создаём нового пользователя и отправляем ему письмо с ссылкой, где он может
  # выбрать сервис авторизации
  def create
    user = User.new
    if save_user(user)
      Mailer.welcome(current_user, user).deliver
      mail = user.email
      flash[:notice] = "Письмо с дальнешими инструкциями отправлено на #{mail}"
    end
    redirect_to users_path
  end
  
  # Изменение почты и имени редактора
  def update
    save_user(@user)
    redirect_to users_path
  end
  
  # Удаление редактора
  def destroy
    # Запрещаем редактору удалять самого себя
    if @user == current_user
      render text: "Нельзя удалить самого себя", status: :bad_request
      return
    end
    
    mail = @user.email
    @user.destroy
    flash[:notice] = "Пользователь #{mail} удалён"
    redirect_to users_path
  end
  
  # Просим пользователя сменить сервис авторизации (например, если он потерял
  # пароль от прошлого).
  def request_auth
    @user.generate_reset_auth_token!
    if current_user == @user
      # Если пользователь хочет сменить свой сервис авторизации, то сразу
      # перенаправляем его на страницу выбора нового
      redirect_to auth_user_path(@user, token: @user.reset_auth_token)
    else
      # Если сервис авторизации нужно сменить для другого пользователя, то
      # отправляем ему письмо
      Mailer.change_auth(current_user, @user).deliver
      mail = @user.email
      flash[:notice] = "Письмо с дальнешими инструкциями отправлено на #{mail}"
      redirect_to users_path
    end
  end
  
  # Пользователь выбирает сервис авторизации и свой auth_uid в этом сервисе
  def auth
    if params[:token].blank?
      render text: 'Не указан токен для смены авторизации', status: :bad_request
    elsif @user.reset_auth_token.blank?
      flash[:error] = 'Пользователь уже выбрал, как войти на сайт'
      redirect_to users_path
    elsif @user.reset_auth_token != params[:token]
      flash[:error] = 'Неправильный ключ для смены способа входа на сайт'
      redirect_to users_path
    else
      session[:reset_auth_token] = params[:token]
    end
  end
  
  private
  
  # Сохраняет новую почту и имя редактора. Если произошли ошибки, то метод их
  # выводит и возврашает false.
  def save_user(user)
    user.name  = params[:user]['name']
    user.email = params[:user]['email']
    user.role  = params[:user]['role']
    if user.save
      true
    else
      # Если новые данные не проходят валидацию (например, почта пустая),
      # то выведем сообщение об ошибке
      flash[:error] = user.errors.full_messages
      false
    end
  end
  
  # Загружаем пользователя из БД. Используется как фильтр, перед нужными
  # действиями.
  def load_user
    @user = User.find(params[:id])
  end
end

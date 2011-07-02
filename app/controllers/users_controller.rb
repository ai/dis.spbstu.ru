# Редакторы сайта
class UsersController < ApplicationController
  # Запрещаем все действия (кроме просмотра списка редакторов) посторонним
  # посетителям
  before_filter :authenticate_user!, except: :index
  
  # Список всех редакторов
  def index
    @users = User.order_by(name: :asc)
  end
  
  # Изменение почты и имени редактора
  def update
    user = User.find(params[:id])
    user.name  = params[:user]['name']
    user.email = params[:user]['email']
    if user.save
      redirect_to users_path
    else
      # Если новые данные не проходят валидацию (например, почта пустая), то
      # вывести сообщение об ошибке
      render :text => user.errors.full_messages, status: :bad_request
    end
  end
  
  # Удаление редактора
  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path
  end
end

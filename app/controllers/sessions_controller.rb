# encoding: utf-8
# Аудентификация редакторов
class SessionsController < ApplicationController
  # Отключаем защиту от XSRF для create действия, чтобы побороть ошибку OmniAuth
  protect_from_forgery except: :create

  # Аудентификация пользователя.
  #
  # Сначала вызывается OmniAuth, который перенаправляет пользователя на
  # сайт аудентификации (например, Google). Если сайт проверил пользователя,
  # то пользователь перенаправляется обратно на наш сайт и вызывается
  # этот метод.
  def create
    provider = auth_hash['provider'] # Сервис, с помощью которого пользователь
                                     # вошёл на сайт (например, с помощью своего
                                     # аккаунта на Google)
    uid  = auth_hash['uid']          # ID пользователя в этом сервисе
    user = User.where(auth_provider: provider, auth_uid: uid).first

    if session[:reset_auth_token]
      # Если пользователь вошёл на сайт первый раз и нам нужно запомнить его
      # сервис и ID пользователя
      reseter = User.where(reset_auth_token: session[:reset_auth_token]).first
      session.delete :reset_auth_token
      if reseter.nil?
        flash[:error] = 'Сменить способ входа уже нельзя'
      elsif user and user != reseter
        flash[:error] = "Этот способ входа уже использует #{user.title}"
      else
        was_confirmed = reseter.confirmed?
        if not reseter.name and auth_hash['user_info']
          reseter.name = auth_hash['user_info']['first_name']
        end
        reseter.auth_provider    = provider
        reseter.auth_uid         = uid
        reseter.reset_auth_token = nil
        sign_in! reseter
        redirect_to was_confirmed ? root_path : start_users_path
        return
      end
    else
      if user
        # Если у нас есть такой редактор
        sign_in! user
      else
        # Если нет — ставим переменную только на следующую сессию, чтобы вывести
        # сообщение об ошибке
        flash[:wrong_user] = auth_hash['user_info']['email']
      end
    end

    # Возвращаем пользователя на страницу, где он последний раз был или на
    # главную страницу сайта
    redirect_to request.env['omniauth.origin'] || root_path
  end

  # Вызывается, если сервис не смог проверить пользователя. Например, если
  # пользователь забыл пароль от своего аккаунта на Google.
  def failure
    flash[:wrong_auth] = params[:message]
    # Возвращаем пользователя на страницу, где он последний раз был или на
    # главную страницу сайта
    redirect_to request.env['omniauth.origin'] || root_path
  end

  # Выход с нашего сайта — забываем, что пользователь вошёл на сайте
  def destroy
    # Меняем session_token пользователя, чтобы он вышел с нашего сайта и с
    # других своих компьютеров (например, если зашёл с компьютера друга и забыл
    # выйти)
    current_user.generate_session_token!
    # Стираем session_token пользователя из сессии
    session.delete :session_token
    # Возвращаем пользователя на страницу, где он последний раз был или на
    # главную страницу сайта
    redirect_to request.referer || root_path
  end

  private

  # Запоминаем, что пользователь вошёл на сайт
  def sign_in!(user)
    user.signin_at = Time.now # Запоминаем время, когда он вошёл на сайт
    user.save
    self.current_user = user  # Ставим session_token
  end

  # Для удобства тестирования сделаем отдельный метод, из которого create берёт
  # данные
  def auth_hash
    request.env['omniauth.auth'] 
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  # Возвращает текущего пользователя, если он вошёл на сайт
  def current_user
    @current_user ||= begin
      token = session[:session_token]
      User.where(session_token: token).first if token
    end
  end
  
  # Проверяем, вошёл ли текущий пользователь на сайт
  def signed_in?
    not current_user.nil?
  end
  
  # Добавляем методы current_user и signed_in? и в шаблоны представления
  helper_method :current_user, :signed_in?
  
  # Запоминаем, что текущий пользователь вошёл на сайт
  def current_user=(user)
    @current_user = user
    session[:session_token] = user.session_token
  end
end

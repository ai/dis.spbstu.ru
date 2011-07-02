# Аудентификация редакторов
class SessionsController < ApplicationController
  # Аудентификация пользователя.
  # 
  # Сначала вызывается OmniAuth, который перенаправляет пользователя на
  # сайт аудентификации (например, Google). Если сайт проверил пользователя,
  # то пользователь перенаправляется обратно на наш сайт и вызывается
  # этот метод.
  def create
    provider = auth_hash['provider']
    uid      = auth_hash['uid']
    user = User.where(auth_provider: provider, auth_uid: uid).first
    
    if user
      user.signin_at = Time.now
      user.save
      self.current_user = user
    else
      flash[:wrong_user] = auth_hash['user_info']['email']
    end
    
    redirect_to request.env['omniauth.origin'] || root_path
  end
  
  # Вызывается в случае ошибки на сайте аудентификации
  def failure
    flash[:wrong_auth] = params[:message]
    redirect_to request.env['omniauth.origin'] || root_path
  end
  
  # Забываем, что пользователь вошёл на сайте
  def destroy
    session.delete :session_token
    redirect_to request.referer || root_path
  end
  
  private
  
  def auth_hash
    request.env['omniauth.auth'] 
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  # Возвращает текущего пользователя, если он вошёл на сайт
  def current_user
    # Используется кеширование: если в переменной @current_user уже есть
    # результат, то мы его сразу и вернём, иначе выполним то, что между
    # begin … end и сохраним результат в @current_user
    @current_user ||= begin
      # Если в сессии выставлен session_token, то ищем пользователя с ним
      token = session[:session_token]
      User.where(session_token: token).first if token
    end
  end
  
  # Проверяем, смотрит ли сайт редактор, который вошёл на сайт или сторонний
  # посетитель
  def signed_in?
    not current_user.nil?
  end
  
  # Добавляем методы current_user и signed_in? и в шаблоны представления
  helper_method :current_user, :signed_in?
  
  # Запоминаем, что текущий пользователь вошёл на сайт и ставим ему в сессию
  # session_token
  def current_user=(user)
    @current_user = user
    session[:session_token] = user.session_token
  end
  
  # Фильтр, который показывает страницу только редакторам. Сторонние посетители
  # увидеят сообщение, что страница закрыта и нужно войти.
  def authenticate_user!
    render 'errors/forbidden', status: :forbidden unless signed_in?
  end
end

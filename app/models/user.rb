# Модель (класс для работы с данными из базы данных) редактора, который может
# изменять тексты на сайте
class User
  include Mongoid::Document
  
  field :name                  # Имя редактора
  field :email                 # Эл. почта редактора
  field :auth_provider         # Сервис, который аудентифицирует пользователя
  field :auth_uid              # ID пользователя в сервисе, который его
                               # аудентификацию
  field :session_token         # Случайная строка, которую мы записываем в
                               # сессию, чтобы знать, что пользователь уже
                               # вошёл на сайт. Как бы «пароль» от сайта.
  field :signin_at, type: Time # Когда пользователь последний раз входил на сайт
  include Mongoid::Timestamps  # Добавляет поля created_at и updated_at, чтобы
                               # знать когда мы создали пользователя, и когда
                               # последний раз изменили
  
  # Проверяем, что эл. почту указали, указали правиль, и что она уникальна
  validates :email, presence: true, email: true, uniqueness: true
  
  # Во время создания пользователя вызываем метод generate_session_token!
  before_create :generate_session_token!
  
  # Создаём индексы, чтобы быстрее искать по каким-то полям
  index [:auth_provider, :auth_uid], unique: true
  index :session_token,              unique: true

  # Генерируемновый новый случайный session_token, по которому проверяем,
  # что пользователь уже вошёл на сайт
  def generate_session_token!
    self.session_token = SecureRandom.base64
  end
end

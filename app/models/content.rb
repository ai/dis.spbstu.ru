# encoding: utf-8
# Модель (класс для работы с данными из базы данных) вики-страницы
class Content
  include Mongoid::Document

  field :path                   # Путь к вики-странице
  field :title                  # Кеш заголовка страницы. Берётся из текста.
  field :deleted_at, type: Time # Отметка, что страница удалена. Не удаляем её
                                # из БД, чтобы всегда можно было откатить
                                # удаление (что-то типа корзины).
  include Mongoid::Timestamps   # Добавляет поля created_at и updated_at,
                                # чтобы знать когда мы создали страницу,
                                # и когда последний раз изменили

  # Версии текста страницы. Там же хранятся авторы изменений.
  embeds_many :versions

  # Проверяем, что указали уникальный путь
  validates :path, presence: true, uniqueness: true

  # Создаём индексы, чтобы быстрее искать страницу по пути
  index :path, unique: true

  # Достаёт страницу (включая удалённые) по пути к ней. Если страницы с таким
  # путём нет, то выкинет ошибку 404.
  def self.by_path(path)
    content = self.where(path: path).first
    raise404 unless content
    content
  end

  # Возвращает страницы, которых не удалили
  def self.undeleted
    where(deleted_at: nil)
  end

  # Выкидывает ошибку 404 (Mongoid::Errors::DocumentNotFound)
  def self.raise404
    raise Mongoid::Errors::DocumentNotFound.new(self.class, [])
  end

  # Переместить в корзину
  def mark_as_deleted!
    self.deleted_at = Time.now
    self.save
  end

  # Восстановить из корзины
  def restore!
    self.deleted_at = nil
    self.save
  end

  # Была ли эта страница отмечена как удалённая
  def deleted?
    not self.deleted_at.nil?
  end

  # Возвращает нужную версию страницы. Если номер версии не передан,
  # то возвращает последнюю версию. Если указанной версии нет, то выкидывает
  # ошибку 404.
  def version(number = nil)
    version = number ? self.versions[number.to_i - 1] : self.versions.last
    self.class.raise404 unless version
    version
  end

  # Возвращает true для главной страницы (у которой адрес /)
  def root?
    '/' == self.path
  end

  # Создаёт новую версию текста страницы и обновляет кеш заголовка
  def update_text!(text, author = nil)
    return if not self.versions.empty? and self.versions.last.text == text
    version = self.versions.create(text: text, author: author)
    self.updated_at = Time.now.utc
    self.title = version.title
    self.save!
  end

  # В JSON-виде отдаём только заголовок и путь
  def as_json(options = { })
    { path: self.path, title: (root? ? 'Главная страница' : self.title) }
  end

  # Возвращает HTML-класс на основе path, чтобы выставить его в <article> и
  # выставлять стили специфичные для определённой страницы.
  def html_class
    root? ? 'root' : path.gsub(/^\//, '').gsub('/', '-').gsub('.', '')
  end

  # Читает HAML-код фильтра. Вынесено из метода filter в отдельный метод для
  # удобства тестирования.
  def filter_haml
    @filter ||= begin
      path = Rails.root.join("app/filters/#{self.html_class}.haml")
      return :no unless File.exists? path
      Haml::Engine.new(File.read(path))
    end
  end

  # Если для страницы есть фильтр, то он использует его, чтобы добавить
  # дополнительную вёрстку.
  def filter(html)
    unless :no == self.filter_haml
      doc = Nokogiri::HTML(html)
      html = self.filter_haml.render(self, html: doc)
    end
    html
  end
end

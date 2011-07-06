# encoding: utf-8
# Модель (класс для работы с данными из базы данных) вики-страницы.
class Content
  include Mongoid::Document
  
  field :path                   # Путь к вики-странице
  field :text                   # Исходный текст страницы
  field :deleted_at, type: Time # Отметка, что страница удалена. Не удаляем её
                                # из БД, чтобы всегда можно было откатить
                                # удаление (что-то типа корзины).
  include Mongoid::Timestamps   # Добавляет поля created_at и updated_at,
                                # чтобы знать когда мы создали страницу,
                                # и когда последний раз изменили
  include Mongoid::Versioning   # Добавляем поддержку старых версий страницы.
                                # При сохранении, текущие данные будут
                                # копироваться в массив versions.
  
  # Редактор, который отредактировал эту версию страницы
  belongs_to :author, class_name: 'User'
  
  # Проверяем, что указали уникальный путь
  validates :path, presence: true, uniqueness: true
  
  # Создаём индексы, чтобы быстрее искать страницу по пути
  index :path, unique: true
  
  # Достаёт страницу (включая удалённые) по пути к ней. Если страницы с таким
  # путём нет, то выкинет ошибку (Mongoid::Errors::DocumentNotFound).
  def self.by_path(path)
    content = self.where(path: path).first
    raise Mongoid::Errors::DocumentNotFound.new(self, []) unless content
    content
  end
  
  # Достаёт страницу по пути к ней. Если страница отмечена как удалённая,
  # то этот метод будет считать, что её нет.
  # Если страницы нет, выкинет ошибку (Mongoid::Errors::DocumentNotFound).
  def self.by_path_without_deleted(path)
    content = self.by_path(path)
    raise Mongoid::Errors::DocumentNotFound.new(self, []) if content.deleted?
    content
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
  
  # Возвращает страницу нужной версии. Если указанной версии нет,
  # то выкинет ошибку 404.
  def get_version(number)
    number = number.to_i if number
    return self if number.nil? or self.version == number
    version = self.versions[number - 1]
    raise Mongoid::Errors::DocumentNotFound.new(self.class, []) unless version
    version
  end
  
  # Запускает рендер и возвращает HTML-версию страницы
  def html
    render
    @html
  end
  
  # Если мы изменили текст, то текущий ренденр устарел и страницу нужно будет
  # перерендерить
  def text=(text)
    @rendered = false
    super # Вызываем оргинальный метод, который выставит новое значение text
  end
  
  private
  
  # Рендерить HTML из markdown-синтаксиса
  def render_html
    @html = Kramdown::Document.new(@text).to_html
  end
  
  # Запускает рендер страницы, если она ещё не рендерилась раньше
  def render
    unless @rendered
      @rendered = true
      @text = self.text
      
      render_html
    end
  end
end

# encoding: utf-8
# Модель (класс для работы с данными из базы данных) вики-страницы.
class Content
  include Mongoid::Document
  
  field :path                   # Путь к вики-странице
  field :text                   # Исходный текст страницы
  field :title                  # Кеш заголовка страницы. Берётся из текста.
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
  # путём нет, то выкинет ошибку 404.
  def self.by_path(path)
    content = self.where(path: path).first
    raise404 unless content
    content
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
  
  # Возвращает страницу нужной версии. Если указанной версии нет,
  # то выкинет ошибку 404.
  def get_version(number)
    number = number.to_i if number
    return self if number.nil? or self.version == number
    version = self.versions[number - 1]
    self.class.raise404 unless version
    version
  end
  
  # Запускает рендер и возвращает HTML-версию страницы
  def html
    process_text
    @html
  end
  
  # Переопределяем метод, который ставит новой текст страницы.
  # Если мы изменили текст, то текущий ренденр устарел и страницу нужно
  # перерендерить
  def text=(text)
    # Вызываем оргинальный метод, который выставит новое значение text
    super
    # Указываем, что кеши устарели и их нужно обновить
    @rendered = false
    @meta_is_parsed = false
    # Парсим мета-информация, чтобы закешировать заголовок
    process_text(:only_meta)
    text
  end
  
  # Описание страницы. Описывается в самом начале статьи после слова
  # «Описание: ».
  def description
    process_text(:only_meta)
    @description
  end
  
  # Ключевые слова страницы. Описываются в самом начале статьи после слов
  # «Ключевые слова: ».
  def keywords
    process_text(:only_meta)
    @keywords
  end
  
  # Возвращает true для главной страницы (у которой адрес /)
  def root?
    '/' == self.path
  end
  
  private
  
  # Извлекает мета-информацию: заголовок, описание и ключевые слова из начала
  # текста страницы
  def parse_meta
    # Удаляем мета-данные, чтобы очистить их, если они не встречается в тексте
    self.title   = nil
    @description = nil
    @keywords    = nil
    loop do
      break unless @text
      line, @text = @text.split("\n", 2) # Отрезаем от начала текста одну строку
      if line.start_with? "Заголовок: "
        self.title = line.sub(/^Заголовок:\s/, '').strip
      
      elsif line.start_with? "Описание: "
        @description = line.sub(/^Описание:\s/, '').strip
        
      elsif line.start_with? "Ключевые слова: "
        @keywords = line.sub(/^Ключевые слова:\s/, '').strip
      
      elsif line =~ /^\s*$/
        # Вырезаем пустые строки
      else
        # Если не метаданные и не пустая строка, то возвращаем строчку обратно
        # в текст и выходим из цикла
        @text = line + "\n" + @text.to_s
        break
      end
    end
  end
  
  # Рендерить HTML из markdown-синтаксиса
  def render_html
    if @text
      @html = Kramdown::Document.new(@text).to_html
    else
      @html = ''
    end
  end
  
  # Обрабатывает текст страницы — извлекает мета-информацию и
  # переводит Markdown в HTML. Кеширует данные и старается лишний раз не
  # выполнять работу. Если нужны только мета-данные, то передайте в первом
  # аргументе true (или :only_meta), долгий рендеринг HTML не будет запущен.
  def process_text(only_meta = false)
    if not @meta_is_parsed
      @text = self.text
      parse_meta
      @meta_is_parsed = true
    end
    if not @rendered and not only_meta
      render_html
      @rendered = true
    end
  end
end

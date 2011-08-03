# encoding: utf-8
# Модель (класс для работы с данными из базы данных) конкретной версии
# вики-страницы
class Version
  include Mongoid::Document

  field :text                          # Исходный текст страницы
  field :version, type: Integer        # Порядкоый номер версии
  include Mongoid::Timestamps::Created # Добавляет поле created_at, чтобы знать
                                       # когда мы создали версию. Поле update_at
                                       # тут не имеет смысла, так как при
                                       # изменении страницы будет просто
                                       # создана новая версия.

  # Редактор, который отредактировал эту версию страницы
  belongs_to :author, class_name: 'User'

  # Создаём ссылку на страницу, в которой хранится эта версия
  embedded_in :content

  # Ставим следующий номер версии при создании
  before_create :set_version_number

  # Является ли эта версия последней версией страницы
  def last?
    self.content.versions.last == self
  end

  # Заголовок страницы. Описываются в самом начале статьи после слова
  # «Заголовок: ».
  def title
    process_text(:only_meta)
    @title
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

  # Запускает рендер и возвращает HTML-версию страницы
  def html
    process_text
    @html
  end

  private

  # Ставит следующий номер версии
  def set_version_number
    self.version = self.content.versions.length
  end

  # Извлекает мета-информацию: заголовок, описание и ключевые слова из начала
  # текста страницы
  def parse_meta
    # Удаляем мета-данные, чтобы очистить их, если они не встречается в тексте
    @title       = nil
    @description = nil
    @keywords    = nil
    loop do
      break unless @text
      line, @text = @text.split("\n", 2) # Отрезаем от начала текста одну строку
      break unless line
      if line.start_with? "Заголовок: "
        @title = line.sub(/^Заголовок:\s/, '').strip

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
    @html = @text ? Kramdown::Document.new(@text).to_html : ''
  end

  # Обрабатывает текст страницы — извлекает мета-информацию и
  # переводит Markdown в HTML. Кеширует данные и старается лишний раз не
  # выполнять работу. Если нужны только мета-данные, то передайте в первом
  # аргументе :only_meta — долгий рендеринг HTML не будет запущен.
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

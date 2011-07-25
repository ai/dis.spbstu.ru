# encoding: utf-8

# Структура для хранения элемента индекса
SearchResult = Struct.new(:id, :title)

# Индекс для быстрого поиска
class SearchIndex
  # Индекс: поисковой запрос → результаты поиска.
  attr_reader :index
  
  def initialize
    @index = { }
  end
  
  # Поиск по заголовокам страниц
  def search(query)
    results = []
    words(query).each do |word|
      if results.empty?
        results  = @index[word]
      else
        results &= @index[word]
      end
    end
    results.sort { |a, b| a.title <=> b.title }
  end
  
  # Добавляет страницу в индекс
  def add(content)
    words(content.title).each_with_index do |word, word_index|
      search = ''
      word.chars.each do |char|
        search += char
        results = @index[search]
        @index[search] = results = [] unless results
        # Слова в начале заголовка имеют большую релевантость
        results << SearchResult.new(content.id, content.title)
      end
    end
  end
  
  # Изымает страницу из индекса
  def remove(content)
    @index.each do |search, results|
      results.delete_if { |i| i.id == content.id }
      @index.delete(search) if results.empty?
    end
  end
  
private
  
  # Разбивает строку на слова
  def words(string)
    string.split(/\s+/).reject { |i| i.empty? }
  end
end

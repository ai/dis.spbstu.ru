# Быстрый поиск по заголовкам страниц
app.search =

  # Список закрытых страниц
  manualPages: []

  # Список всех страниц сайта
  pages: null

  # Загружен ли уже список страниц
  initialized: false

  # В процессе ли загрузка списка страниц
  initializing: false

  # Последний поисковой запрос, выолненный пока список страниц ещё грузился.
  # Как только список страниц будет загружен, этот запрос будет выполнен.
  lastSearch: null

  # Добавляет страницу в индекс. Нужно для того, чтобы в поиск редакторов
  # добавить закрытые страницы.
  add: (path, title) ->
    @manualPages.push(path: path, title: title)

  # Загрузить и подготовить индекс, если он ещё не готов
  init: ->
    @loadIndex() unless @initialized and @initializing

  # Загружает список всех страниц с сайта
  loadIndex: ->
    @initializing = true
    $.get '/all.json', (pages) =>
      @pages = pages.concat(@manualPages)
      @processIndex()
      @initialized = true
      @query.apply(@lastSearch) if @lastSearch?

  # Разрезает заголовок на отдельные слова, чтобы потом было быстрее искать
  processIndex: ->
    for page in @pages
      if page.title?
        page.words = page.title.toLocaleLowerCase().split(/\s+/)
      else
        page.words = []

  # Поиск страниц, заголовок которых начинается с query. Результаты поиска
  # будут переданны в функцию callback.
  query: (query, callback) ->
    if '' == query
      callback([])
      @lastSearch = null
      return

    unless @initialized
      @lastSearch = arguments
      @init()
      return

    starts = query.toLocaleLowerCase().split(/\s+/)
    finded = []
    for page in @pages
      count = 0
      for start in starts
        for word in page.words
          if word[0...start.length] == start
            count += 1
            break
      if count == starts.length
        page.highlighted = @highlight(page.title, starts)
        finded.push(page)

    callback(finded)

  # Подсвечивает найденные слова в заголовке страницы
  highlight: (title, starts) ->
    highlighted = title
    for start in starts
      lower = highlighted.toLocaleLowerCase()
      from = lower.indexOf(start)
      if from > -1
        to = from + start.length
        highlighted = highlighted[0...from] +
                      '<strong>' + highlighted[from...to] + '</strong>' +
                      highlighted[to..-1]
    highlighted

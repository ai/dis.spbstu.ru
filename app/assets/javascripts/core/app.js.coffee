window.app =
  # Выводит переменные или текст в консоль браузера. В отличии от console.log
  # не сломает JS, если у браузера нет консоли.
  log: ->
    console?.log?.apply(console, arguments)
  
  # Возвращает вендроный префикс браузера для новых API.
  prefix: ->
    return 'moz'    if $.browser.mozilla
    return 'webkit' if $.browser.webkit
    return 'o'      if $.browser.opera
    return 'ms'     if $.browser.msie
  
  # Проверяет размер экрана или поддержку технологий с помощью
  # CSS Media Queries. Просто обёртка вокруг window.matchMedia().
  media: (media) ->
    return false unless window.matchMedia?
    result = matchMedia("all and (#{media})")
    return true if result.matches
    matchMedia("all and (-#{app.prefix()}-#{media})").matches
  
  # Позволяет указать код, для какой-то конкретной страницы — выполянет
  # `callback` только, если на странице есть selector. В `callback` первым
  # параметром передаёт jQuery, вторым — фукнкцию jQuery-поиска только
  # внутри `selector` (чтобы JS был быстрее), а третьим — jQuery-объект для
  # `selector`.
  for: (selector, callback) ->
    jQuery ($) ->
      content = $(selector)
      if content.length
        $$ = (selector) ->
          $(selector, content)
        callback.apply content, [ $, $$, content ]

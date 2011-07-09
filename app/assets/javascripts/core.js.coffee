window.app =
  # Выводит переменные или текст в консоль браузера. В отличии от console.log
  # не сломает JS, если у браузера нет консоли.
  log: ->
    console?.log?.apply(console, arguments)

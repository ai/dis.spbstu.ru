app.for '#menu', ($, $$) ->
  
  # Показываем полное название кафедры при наведении на логотип

  ul     = $('ul')
  full   = $('.full-name')
  home   = $$('[rel=home]')
  naming = null
  home.mouseenter ->
    naming = after '0.5sec', ->
      full.width(ul.width() - 2)
      full.addClass('show')
  home.mouseleave ->
    clearTimeout(naming)
    full.removeClass('show')
  home.click ->
    clearTimeout(naming)

  # Показывает подсказку в поиске, что надо нажать Enter
  
  icons = $$('.search .submit-by-enter, .search .icon')
  $$('.search input').
    focus(-> icons.addClass('focus')).blur(-> icons.removeClass('focus'))

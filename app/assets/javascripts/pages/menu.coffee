app.for '#menu', ($, $$) ->
  
  # Показываем полное название кафедры при наведении на логотип

  ul     = $('ul')
  full   = $('.full-name')
  home   = $$('[rel=home]')
  naming = null
  home.mouseenter ->
    naming = after '0.5sec', ->
      full.stop().animate(width: ul.width() - 4, 200)
  home.mouseleave ->
    clearTimeout(naming)
    full.stop().animate(width: 0, 200)

  # Показывает подсказку в поиске, что надо нажать Enter
  
  icons = $$('.search .submit-by-enter, .search .icon')
  $$('.search input').
    focus(-> icons.addClass('focus')).blur(-> icons.removeClass('focus'))

app.for '#menu', ($, $$) ->
  
  # Показывает подсказку в поиске, что надо нажать Enter
  
  icons = $$('.search .submit-by-enter, .search .icon')
  $$('.search input').
    focus(-> icons.addClass('focus')).blur(-> icons.removeClass('focus'))

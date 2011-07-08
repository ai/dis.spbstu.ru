# =require 'lib/jquery.easing'

jQuery ($) ->
  
  # Воявление формы входа на сайт
  signin = $('.signin-form')
  $('#controls.signin').dblclick ->
    left = signin.css('left')
    height = $('#subroot').height() - parseInt(signin.css('marginTop'))
    if height > signin.outerHeight()
      signin.show().animate(left: 0, 500, 'easeOutBack')
    else
      byFade = true
      signin.css(left: 0).fadeIn(500)
    $('body').bind 'click.hide-signin', (e) ->
      unless $(e.target).closest('.signin-form').length
        $('body').unbind('click.hide-signin')
        if byFade
          signin.fadeOut 500, -> signin.css(left: left)
        else
          signin.animate left: left, 500, 'easeInOutCubic', -> signin.hide()
    false
  
  # Отправка формы с помощью ссылки
  $('[role=submit]').click ->
    $(@).closest('form').submit()
    false

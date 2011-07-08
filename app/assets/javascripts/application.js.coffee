# =require 'lib/jquery.easing'

jQuery ($) ->
  
  # Воявление формы входа на сайт
  $('#controls.signin').dblclick ->
    left = $('.signin-form').css('left')
    $('.signin-form').animate(left: 0, 500, 'easeOutBack')
    $('body').bind 'click.hide-signin', (e) ->
      unless $(e.target).closest('.signin-form').length
        $('body').unbind('click.hide-signin')
        $('.signin-form').animate(left: left, 500, 'easeInOutCubic')
    false
  
  # Отправка формы с помощью ссылки
  $('[role=submit]').click ->
    $(@).closest('form').submit()
    false

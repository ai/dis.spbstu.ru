app.for '@signin-form', ($, $$, form) ->
  
  # Появление формы входа на сайт
  $('@show-signin').dblclick ->
    left = form.css('left')
    height = $('#subroot').height() - parseInt(form.css('marginTop'))
    if height > form.outerHeight()
      form.show().animate(left: 0, 500, 'easeOutBack')
    else
      byFade = true
      form.css(left: 0).fadeIn(500)
      
    $('body').bind 'click.hide-signin', (e) ->
      unless $(e.target).closest('@signin-form').length
        $('body').unbind('click.hide-signin')
        if byFade
          form.fadeOut 500, -> form.css(left: left)
        else
          form.animate left: left, 500, 'easeInOutCubic', -> form.hide()
    false

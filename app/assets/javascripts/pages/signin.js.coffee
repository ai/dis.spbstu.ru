app.for '@signin-form', ($, $$, form) ->

  # Появление формы входа на сайт
  $('#controls').dblclick ->
    return if form.is(':animated')

    left = form.css('left')
    height = $('#subroot').outerHeight() - parseInt(form.css('top'))
    if height > form.outerHeight()
      form.show().animate(left: 0, 500, 'easeOutBack')
    else
      byFade = true
      form.css(left: 0).fadeIn(500)

    $('body').bind 'click.hide-signin', (e) ->
      return if form.is(':animated')
      unless $(e.target).closest('@signin-form').length
        $('body').unbind('click.hide-signin')
        if byFade
          form.fadeOut 500, -> form.css(left: left)
        else
          form.animate left: left, 500, 'easeInOutCubic', -> form.hide()
    false

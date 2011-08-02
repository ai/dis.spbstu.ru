window.app.flash =

  # Прячет flash-уведомление
  hide: (flash) ->
    return if flash.data('hiding')
    flash.data('hiding', true)

    height = flash.outerHeight()
    if app.media('transform-3d')
      transform = app.css3prop('transform')

      div = flash.find('div')
      div.css(borderTopWidth: height, top: -height)

      $({ i: 0 }).animate { i: 1 },
        duration: 600
        easing: 'easeInQuart'
        step: (i) ->
          angle = Math.round(i * 90)
          div.css(transform, "rotateX(#{angle}deg)")
        complete: ->
          flash.remove()
    else
      flash.animate top: -height + 3, 600, 'easeInQuart', ->
        flash.remove()

  # Автоматически скрывает flash-уведомление
  alive: (flash) ->
    return unless flash.length
    Visibility.onVisible ->
      after '2.5sec', -> app.flash.hide(flash)
    flash.click -> app.flash.hide(flash)

jQuery ($) ->
  app.flash.alive($('.flash'))

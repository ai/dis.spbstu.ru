# =require 'lib/jquery.chrono'

window.app.flash =
  # Прячет flash-уведомление
  hide: (flash) ->
    return if flash.data('hiding')
    flash.data('hiding', true)
    
    height = flash.outerHeight()
    if app.media('transform-3d')
      prop = 'transform'
      prop = "-#{app.prefix()}-#{prop}" unless document.body.style.transform?
      
      div  = flash.find('div')
      div.css(borderTopWidth: height, top: -height)
      
      flash.animate { i: 1 },
        duration: 600
        easing: 'easeInQuart'
        step: (i) ->
          angle = Math.round(i * 90)
          div.css(prop, "rotateX(#{angle}deg)")
        complete: ->
          flash.remove()
    else
      flash.animate top: -height + 3, 600, 'easeInQuart', ->
        flash.remove()
  
  # Автоматически скрывает flash-уведомление
  alive: (flash) ->
    return unless flash.length
    $.after '2.5sec', -> app.flash.hide(flash)
    flash.click -> app.flash.hide(flash)

jQuery ($) ->
  app.flash.alive($('.flash'))

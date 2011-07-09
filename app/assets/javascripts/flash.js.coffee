# =require 'lib/jquery.chrono'

window.app.flash =
  # Прячет flash-уведомление
  hide: (flash) ->
    flash.animate top: -flash.outerHeight() + 3, 600, 'easeInQuart', ->
      flash.remove()
  
  # Автоматически скрывает flash-уведомление
  alive: (flash) ->
    return unless flash.length
    $.after '2.5sec', -> app.flash.hide(flash)
    flash.click -> app.flash.hide(flash)

jQuery ($) ->
  app.flash.alive($('.flash'))

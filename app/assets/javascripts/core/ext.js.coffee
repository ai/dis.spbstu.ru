(($) ->
  
  $.fn.extend
    
    # Надоит ближайший тег form и отправляет его содержимое на сервер
    submitForm: ->
      @closest('form').submit()
      @
  
  window.after = $.after
  window.every = $.every
  
)(jQuery)

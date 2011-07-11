jQuery ($) ->
  
  # Отправка формы с помощью ссылки
  $('[role=submit]').click ->
    $(@).submitForm()
    false

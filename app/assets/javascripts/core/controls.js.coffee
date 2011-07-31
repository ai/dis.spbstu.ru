jQuery ($) ->
  
  # Отправка формы с помощью ссылки
  $('@submit').click ->
    $(@).submitForm()
    false

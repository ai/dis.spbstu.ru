app.for 'article.users', ($, $$) ->

  # Показываем кнопку Сохранить при редактировании редакторов
  userEdit = $$('input')
  userEdit.focus ->
    li = $(@).closest('li')
    li.find('@user-controls').hide()
    li.find('@save-user').css(display: 'inline-block')
  userEdit.change ->
    $(@).closest('li').data(changed: true)
  userEdit.blur ->
    li = $(@).closest('li')
    unless li.data('changed')
      li.find('@save-user').hide()
      li.find('@user-controls').show()

  # Подтверждение удаления пользователя
  $$('@delete-user').click ->
    email = $(@).closest('li').find('[type=email]').val()
    $(@).submitForm() if confirm("Точно удалить пользователя #{email}?")

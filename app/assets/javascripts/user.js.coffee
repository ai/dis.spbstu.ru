# =require 'lib/jquery.elastic'

jQuery ($) ->
  # Изменение стиля панели инструментов, когда курсор на неё наводится
  $('#controls').hover(
    -> $(this).removeClass('unhover'),
    -> $(this).addClass('unhover'))
  
  # Копируем текст кнопки, чтобы при затемнённой панели инструментов показывать
  # вместо кнопок только серый текст и границу
  $('.shadowed-button').each ->
    label = $(@).find('.styled-button').text()
    $('<span></span>').prependTo(@).text(label)
  
  # Связываем кнопку сохранения страницы из панели инструментов с формой
  $('#controls [role=save-content]').click ->
    $('article form').submit()
    false
  
  # Сохранение страницы по Ctrl + Enter
  $('article.edit-content textarea').elastic().keydown (e) ->
    $(@).closest('form').submit() if 13 == e.keyCode and e.metaKey
  
  # Показываем кнопку Сохранить при редактировании редакторов
  userEdit = $('article.users input')
  userEdit.focus ->
    $(@).closest('li').find('.controls').hide()
    $(@).closest('form').find('.styled-button').css(display: 'inline-block')
  userEdit.change ->
    $(@).closest('form').data(changed: true)
  userEdit.blur ->
    form = $(@).closest('form')
    unless form.data('changed')
      form.find('.styled-button').hide()
      $(@).closest('li').find('.controls').show()
  
  # Подтверждение удаления пользователя
  $('article.users [role=delete] .styled-button').click ->
    email = $(@).closest('li').find('[type=email]').val()
    if confirm("Точно удалить пользователя #{email}?")
      $(@).closest('form').submit()

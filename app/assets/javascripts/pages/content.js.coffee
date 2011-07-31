app.for 'article.edit-content', ($, $$) ->
  textarea = $$('@content-textarea')

  # Связываем кнопку сохранения страницы из панели инструментов с формой
  $('@save-content').click ->
    textarea.submitForm()
    false

  # Сохранение страницы по Ctrl + Enter
  textarea.elastic().keydown (e) ->
    $(@).submitForm() if 13 == e.keyCode and e.metaKey

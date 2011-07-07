# =require 'lib/jquery.elastic'

jQuery ($) ->
  # Изменение стиля панели инструментов, когда курсор на неё наводится
  $('#controls').hover(
    -> $(this).removeClass('unhover'),
    -> $(this).addClass('unhover'))
  
  # Копируем текст кнопки, чтобы при затемнённой панели инструментов показывать
  # вместо кнопок только серый текст и границу
  $('#controls .shadowed-button').each ->
    label = $(@).find('.styled-button').text()
    $('<span></span>').prependTo(@).text(label)
  
  # Связываем кнопку сохранения страницы из панели инструментов с формой
  $('#controls [role=save-content]').click ->
    $('article form').submit()
    false
  
  # Сохранение страницы по Ctrl + Enter
  $('article.edit-content textarea').elastic().keydown (e) ->
    $(@).closest('form').submit() if 13 == e.keyCode and e.metaKey
  
  

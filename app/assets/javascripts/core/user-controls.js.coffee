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

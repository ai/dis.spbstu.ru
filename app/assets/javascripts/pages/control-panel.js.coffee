jQuery ($) ->

  # Изменение стиля панели инструментов, когда курсор на неё наводится
  $('#controls').hover(
    -> $(this).removeClass('unhover'),
    -> $(this).addClass('unhover'))

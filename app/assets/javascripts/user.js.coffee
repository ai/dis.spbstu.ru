jQuery ($) ->
  $('#controls').hover(
    -> $(this).removeClass('unhover'),
    -> $(this).addClass('unhover'))
  
  $('#controls .shadowed-button').each ->
    label = $(@).find('.styled-button').text()
    $('<span></span>').prependTo(@).text(label)

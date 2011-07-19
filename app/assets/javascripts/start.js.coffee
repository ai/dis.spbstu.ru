jQuery ($) ->
  
  $('article.start .old-browser').show() if $.browser.msie
  
  $('#controls').addClass('signin')
  
  $('@test-signin a').click ->
    $('@signin-form').addClass('passed')
    $('@test-signin').addClass('passed')
    $('.signin-help').hide()
    after '2sec', ->
      $('body').click()
      after '500ms', -> $('@signin-form').removeClass('passed')
    false
  
  $('@exit').submit ->
    $('@test-exit').addClass('passed')
    false

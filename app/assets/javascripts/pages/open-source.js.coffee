app.for '#opensource', ($, $$, link) ->

  # 2 разных анимации, которые будут показывать «исходный код» сайта,
  # в зависимости от возможностей браузера
  if app.media('transform-3d')
    corner = $$('.corner')
    animation = null
    link.hover ->
      back = !link.is(':hover')
      prop = 'transform'
      prop = "-#{app.prefix()}-#{prop}" unless document.body.style.transform?
      animation?.stop()

      animation = $({ i: 0 }).animate { i: 1 },
        duration: 600
        easing:  'easeInOutQuad'
        step: (i) ->
          angle = Math.round(i * 180)
          angle = 180 - angle if back
          corner.css(prop, "rotate3d(1, 1, 0, #{angle}deg)")
  else
    link.addClass('animated2d')

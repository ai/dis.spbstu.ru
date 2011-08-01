app.for '#opensource', ($, $$, opensource) ->
  link = $$('.repository')

  # 2 разных анимации, которые будут показывать «исходный код» сайта,
  # в зависимости от возможностей браузера
  if app.media('transform-3d')
    light     = $$('.light')
    shadow    = $$('.shadow')
    corner    = $$('.corner')
    animation = null
    link.hover ->
      back = !link.is(':hover')
      prop = 'transform'
      prop = "-#{app.prefix()}-#{prop}" unless document.body.style.transform?
      animation?.stop()

      link.removeClass('bended') if back
      animation = $({ i: 0 }).animate { i: 1 },
        duration: 600
        easing:  'easeInOutQuad'
        step: (i) ->
          angle = Math.round(i * 180)
          if back
            angle = 180 - angle
            if i < 0.5
              shadow.css(opacity: i / 6)
            else
              shadow.css(opacity: 0)
              light.css(opacity: 2 * (1 - i))
          else
            if i < 0.5
              light.css(opacity: 2 * i)
            else
              light.css(opacity: 0)
              shadow.css(opacity: (1 - i) / 6)
          corner.css(prop, "rotate3d(1, 1, 0, #{angle}deg)")
          if i > 0.85 and not back
            link.addClass('bended')
  else
    link.addClass('animated2d')

  # Показываем/скрываем текст и технологии сайта

  hack  = $$('.hack')
  techs = $$('.technologies')
  techsAnimation = null
  period = 0.5 / techs.find('li').length
  link.mouseover ->
    techsAnimation?.stop()
    next = techs.find('li:first')
    time = 0.5

    techsAnimation = $({ i: 0 }).animate { i: 1 },
      duration: 1200
      step: (i) ->
        if time > 0.5
          hack.addClass('show')
        if time < i
          time += period
          next.addClass('show')
          next = next.next()
  link.mouseout ->
    techsAnimation?.stop()
    next = techs.find('li:last')
    time = 0

    hack.removeClass('show')
    techsAnimation = $({ i: 0 }).animate { i: 1 },
      duration: 600
      step: (i) ->
        if time < i
          time += period
          next.removeClass('show')
          next = next.prev()

app.for '#opensource', ($, $$, opensource) ->
  link = $$('.repository')

  # 2 разных анимации, которые будут показывать «исходный код» сайта,
  # в зависимости от возможностей браузера
  if app.media('transform-3d')
    opensource.addClass('animated3d')
    light     = $$('.light')
    shadow    = $$('.shadow')
    corner    = $$('.corner')
    animation = $({ i: 0 })
    link.hover ->
      back = !link.is(':hover')
      prop = 'transform'
      prop = "-#{app.prefix()}-#{prop}" unless document.body.style.transform?

      link.removeClass('bended') if back
      animation.stop().animate { i: (if back then 0 else 1) },
        duration: 600
        easing:  'easeInOutQuad'
        step: (i) ->
          angle = Math.round(i * 180)
          if i < 0.5
            light.css(opacity: 2 * i)
            shadow.css(opacity: 0)
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
  techsAnimation = $({ i: 0 })
  period = 0.5 / techs.find('li').length
  link.mouseenter ->
    techs.show()
    hack.show()
    next = techs.find('li:first')
    time = 0.5

    techsAnimation.stop().animate { i: 1 },
      duration: 1200
      easing:  'easeInOutQuad'
      step: (i) ->
        if time > 0.5
          hack.addClass('show')
        if time < i
          time += period
          next.addClass('show')
          next = next.next()
  link.mouseleave ->
    next = techs.find('li:last')
    time = 1

    hack.removeClass('show')
    techsAnimation.stop().animate { i: 0 },
      duration: 600
      easing:  'easeInOutQuad'
      step: (i) ->
        if time > i
          time -= period
          next.removeClass('show')
          next = next.prev()
      complete: ->
        hack.hide()
        techs.hide()

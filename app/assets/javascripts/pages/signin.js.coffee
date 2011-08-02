app.for '#controls.signin', ($, $$, signin) ->

  form = $$('.signin-form')

  # 2 анимации появление формы входа на сайт в зависимости от возможностей
  # браузера

  closeBy = (closing) ->
    ->
      $('body').bind 'click.hide-signin', (e) ->
          unless $(e.target).closest(form).length
            $('body').unbind('click.hide-signin')
            closing()

  openBy = (animated, opening) ->
    signin.dblclick ->
      return if animated.is(':animated')
      opening()

  unless app.media('transform-3d')
    openBy form, ->
      form.fadeIn 600, closeBy ->
        form.fadeOut(600)
  else
    signin.addClass('animated3d')
    animation = $({ i: 1 })
    transform = app.css3prop('transform')

    rotator   = $$('.rotator')
    light     = $$('.light')
    shadow    = $$('.shadow')

    rotate = (to, callback) ->
      light.add(shadow).addClass('show')
      rotator.addClass('bordered')
      animation.animate { i: to },
        duration: 600
        easing:  'easeInOutQuad'
        step: (i) ->
          angle = Math.round(i * 180)
          rotator.css(transform, "rotateY(-#{angle}deg)")
          if i < 0.5
            form.css(opacity: 1)
            light.css(opacity: 2 * i)
            shadow.css(opacity: 0)
          else
            form.css(opacity: 0)
            light.css(opacity: 0)
            shadow.css(opacity: (1 - i) / 6)
        complete: ->
          light.add(shadow).removeClass('show')
          rotator.removeClass('bordered')
          callback?()

    openBy animation, ->
      form.addClass('show')
      rotate 0, closeBy ->
        rotate 1, -> form.removeClass('show')

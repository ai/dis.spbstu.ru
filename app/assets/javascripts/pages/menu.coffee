app.for '#menu', ($, $$) ->
  
  # Показываем полное название кафедры при наведении на логотип

  ul     = $('ul')
  full   = $('.full-name')
  home   = $$('[rel=home]')
  naming = null
  home.mouseenter ->
    naming = after '0.5sec', ->
      full.width(ul.width() - 2)
      full.addClass('show')
  home.mouseleave ->
    clearTimeout(naming)
    full.removeClass('show')
  home.click ->
    clearTimeout(naming)

  # Поиск
  
  search    = $$('@search')
  quick     = $$('@quick-search-results')
  searchKey = $$('@search-key')
  form      = $$('form')
  quickResult = (page) ->
    "<li><a href='#{page.path}'>#{page.highlighted}</a></li>"
  
  lastQuery = null
  selected  = null
  
  search.focus ->
    form.addClass('focused')
    app.search.init()
    quick.show() if quick.find('li').length > 0
  
  search.blur ->
    form.removeClass('focused')
    quick.hide()
    app.search.lastSearch = null
  
  search.bind 'keyup change search', (e) ->
    query = $.trim(search.val())
    return if query == lastQuery
    lastQuery = query
    
    searchKey.toggleClass('enter', (query != ''))
    app.search.query query, (pages) ->
      if 0 == pages.length
        quick.hide().find('ol').html('')
        return
      
      html = ''
      for page in pages
        html += "<li><a href='#{page.path}'>#{page.highlighted}</a></li>"
      
      quick.show().
        find('ol').html(html).
        find('li:first').addClass('down')
      selected = null
    
  search.keyup (e) ->
    return unless quick.find('li').length
    
    if e.keyCode == 38 # Вверх
      if selected
        selected.removeClass('selected').addClass('down')
        selected.next().removeClass('down')
        prev = selected.prev()
        if prev.length
          selected = prev.removeClass('up').addClass('selected')
          prev = selected.prev()
          if prev.length
            prev.addClass('up')
          else
            searchKey.addClass('up')
        else
          searchKey.removeClass('up').addClass('enter')
          selected = null
    
    else if e.keyCode == 40 # Вниз
      if selected
        next = selected.next()
        if next.length
          searchKey.removeClass('up')
          selected.prev().removeClass('up')
          selected.removeClass('selected').addClass('up')
          selected = next.addClass('selected')
          next = selected.next()
          next.addClass('down')
      else
        searchKey.removeClass('enter').addClass('up')
        selected = quick.find('li:first')
        selected.removeClass('down').addClass('selected')
        selected.next().addClass('down')
  
  search.closest('form').submit ->
    if selected
      location.href = selected.find('a').attr('href')
      false

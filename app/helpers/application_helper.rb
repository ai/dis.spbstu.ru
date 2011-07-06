# encoding: utf-8
module ApplicationHelper
  
  # Возвращает путь, по которому можно исправить содержимое страницы
  def edit_content_path(content)
    return '/edit' if '/' == content.path
    content.path + '/edit'
  end
  
  # Добавляет ссылку на jQuery. В production использует сервера Яндекс, во время
  # разработки использует локальную версию.
  def include_jquery
    if Rails.env.production?
      url = 'http://yandex.st/jquery/1.6.2/jquery.min.js'
    else
      url = 'lib/development/jquery-1.6.2.js'
    end
    javascript_include_tag(url)
  end
  
end

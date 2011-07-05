module ApplicationHelper
  
  # Возвращает путь, по которому можно исправить содержимое страницы
  def edit_content_path(content)
    return '/edit' if '/' == content.path
    content.path + '/edit'
  end
  
end

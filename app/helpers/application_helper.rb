# encoding: utf-8
# Глобальные хелперы
module ApplicationHelper
  
  # Указывает заголовок веб-страницы. К нему будет ещё добавлено название сайта.
  def title(title)
    content_for(:title) { title }
  end
  
  # Возвращает путь, по которому можно исправить содержимое страницы
  def edit_content_path(path)
    path = path.path if path.is_a? Content
    (path.ends_with? '/') ? "#{path}edit" : "#{path}/edit"
  end
  
  # Вставляет в HAML класс, если условие в check верное
  def class_if(cls, check)
    check ? { class: cls } : { }
  end
  
end

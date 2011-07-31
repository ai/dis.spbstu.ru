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

  # Вставляет ещё одно значение в html-аттрибут, который допускает перечисление
  # значений через пробел (например, class или role).
  def add_attr(options, add)
    add.each_pair do |name, value|
      if options[name]
        options[name] = "#{options[name]} #{value}"
      else
        options[name] = value
      end
    end
  end

  # Вставляет кнопку-стрелку
  def go_button(text, options = {})
    options[:href] ||= '#'
    add_attr(options, class: 'go-button')
    span  = content_tag(:span, text)
    arrow = content_tag(:div,  content_tag(:div, ''), class: 'arrow')
    crop  = content_tag(:div,  arrow, class: 'crop')
    content_tag(:a, span + crop, options)
  end

  # Красивая закруглённая кнопка
  def button(text, options = {})
    options[:href] ||= '#'
    add_attr(options, class: 'styled-button')
    content_tag(:a, content_tag(:span, text), options)
  end

  # Аналог хеплера button, только добавляет role="submit", в результате кнопка
  # отправлят форму по нажатию
  def submit_button(text, options = {})
    add_attr(options, role: 'submit')
    button(text, options)
  end

  # Оборачивает кнопку из хелпера button в .shadowed-button, чтобы она не сильно
  # бросалась в глаза, пока пользователь на неё не наведёт курсор. Использует в
  # панели управления.
  def shadowed_button(text, options = {})
    span = content_tag(:span, text)
    btn  = button(text, options)
    content_tag(:div, span + btn, class: 'shadowed-button')
  end

end

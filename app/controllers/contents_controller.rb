# encoding: utf-8
# Вики-страницы
class ContentsController < ApplicationController
  # Запрещаем редактирование и удаление страниц посторонним посетителям
  before_filter :authenticate_user!, except: :show
  
  # Добавляем в самое начала параметра path ведущий /
  before_filter :fix_path
  
  # Отображение вики-страниц
  def show
    # Ищем страницу по текущему пути. Если страницу не будет найдена, то будет
    # выброшена ошибка 404 (Mongoid::Errors::DocumentNotFound).
    @content = Content.by_path_without_deleted(params[:path])
    @version = @content.get_version(params[:version])
  end
  
  # Страница редактирования
  def edit
    @content = Content.find_or_initialize_by(path: params[:path])
  end
  
  # Сохраняем вики-страницу
  def update
    content = Content.find_or_initialize_by(path: params[:path])
    content.text   = params[:content]['text']
    content.author = current_user
    content.save
    redirect_to content.path
  end
  
  # Удаляем вики-страницу
  def destroy
    content = Content.by_path(params[:path])
    # Не удаляем, а только помечаем страницу к удалению.
    # Так её всегда можно будет восстановить «из корзины».
    content.mark_as_deleted!
    flash[:notice] = "Страница #{content.path} была помещена в корзину"
    redirect_to content.path
  end
  
  # Восстановление страницы после удаления
  def restore
    content = Content.by_path(params[:path])
    content.restore!
    redirect_to content.path
  end
  
  private
  
  # Добавляем в path вперёд /, если его там нет.
  # Используется как фильтр, перед всеми действиями.
  def fix_path
    params[:path] = '/' + params[:path] unless params[:path].start_with? '/'
  end
end

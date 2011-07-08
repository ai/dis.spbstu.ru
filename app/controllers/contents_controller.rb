# encoding: utf-8
# Вики-страницы
class ContentsController < ApplicationController
  # Запрещаем редактирование и удаление страниц посторонним посетителям
  before_filter :authenticate_user!, except: :show
  
  # Добавляем в самое начала параметра path ведущий /
  before_filter :fix_path
  
  # Загружаем страницу из БД для действий, где она нужна
  before_filter :load_content, only: [:show, :destroy, :restore]
  
  # Загружаем страницу из БД или создаём новую
  before_filter :load_or_initialize_content, only: [:edit, :update]
  
  # Отображение вики-страниц
  def show
    # Ищем страницу по текущему пути. Если страницу не будет найдена, то будет
    # выброшена ошибка 404 (Mongoid::Errors::DocumentNotFound).
    Content.raise404 if @content.deleted?
    @version = @content.version(params[:version])
  end
  
  # Страница редактирования
  def edit
  end
  
  # Сохраняем вики-страницу
  def update
    @content.update_text! params[:text], current_user
    redirect_to @content.path
  end
  
  # Удаляем вики-страницу
  def destroy
    # Не удаляем, а только помечаем страницу к удалению.
    # Так её всегда можно будет восстановить «из корзины».
    @content.mark_as_deleted!
    flash[:notice] = "Страница #{@content.path} была помещена в корзину"
    redirect_to @content.path
  end
  
  # Восстановление страницы после удаления
  def restore
    @content.restore!
    redirect_to @content.path
  end
  
  private
  
  # Добавляем в path вперёд /, если его там нет.
  # Используется как фильтр, перед всеми действиями.
  def fix_path
    params[:path] = '/' + params[:path] unless params[:path].start_with? '/'
  end
  
  # Загружаем страницу из БД. Используется как фильтр, перед нужными
  # действиями.
  def load_content
    @content = Content.by_path(params[:path])
  end
  
  # Загружаем страницу из БД. Если такой страницы ещё нет, то создаём её.
  # Используется как фильтр, перед нужными действиями.
  def load_or_initialize_content
    @content = Content.find_or_initialize_by(path: params[:path])
  end
end

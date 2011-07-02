class UsersController < ApplicationController
  before_filter :authenticate_user!, except: :index
  
  def index
    @users = User.order_by(name: :asc)
  end
  
  def update
    user = User.find(params[:id])
    user.name  = params[:user]['name']
    user.email = params[:user]['email']
    if user.save
      redirect_to users_path
    else
      render :text => user.errors.full_messages, status: :bad_request
    end
  end
  
  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path
  end
end

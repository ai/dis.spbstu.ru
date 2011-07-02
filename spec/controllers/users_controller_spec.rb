# encoding: utf-8

require 'spec_helper'

describe UsersController do
  
  describe "#index" do
  
    it "should display all users" do
      one = Fabricate(:user, name: 'Борис')
      two = Fabricate(:user, name: 'Андрей')
      
      get :index
      
      response.should be_success
      assigns(:users).to_a.should == [two, one]
    end
    
  end
  
  describe "#update" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      put :update, id: @user.id
      response.should be_forbidden
    end
    
    it "should not allow to set empty email" do
      put :update, id: @user.id, user: { 'email' => '' }
      response.status.should == 400 # bad request
      @user.reload.email.should_not be_blank
    end
    
    it "should update user" do
      put :update, id: @user.id,
                   user: { 'email' => 'new@example.com', 'name' => 'New' }
      
      response.should redirect_to(users_path)
      @user.reload
      @user.email.should == 'new@example.com'
      @user.name.should  == 'New'
    end
    
  end
  
  describe "#destroy" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      delete :destroy, id: @user.id
      response.should be_forbidden
    end
    
    it "should delete user" do
      one = Fabricate(:user)
      User.count.should == 2
      
      delete :destroy, id: one.id
      
      response.should redirect_to(users_path)
      User.count.should == 1
    end
    
  end

end

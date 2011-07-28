# encoding: utf-8
require 'spec_helper'

describe UsersController do
  render_views # Проверяет, что в шаблонах нет синтаксических ошибок
  
  describe "#index" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      get :index, id: @user.id
      response.should be_forbidden
    end
  
    it "should display all users" do
      one = Fabricate(:user, name: 'Борис')
      two = Fabricate(:user, name: 'Андрей')
      
      get :index
      
      response.should be_success
      assigns(:users).to_a.should == [@user, two, one]
    end
    
  end
  
  describe "#auth" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      put :update, id: @user.id
      response.should be_forbidden
    end
  
    it "should not allow to set auth without token" do
      get :auth, id: @user.id
      
      response.should be_bad_request
      response.body.should include('Не указан токен')
      session[:reset_auth_token].should be_nil
    end
  
    it "should not allow to set auth for user without token" do
      @user.update_attribute :reset_auth_token, nil
      
      get :auth, id: @user.id, token: '123'
      
      response.should redirect_to(users_path)
      flash[:error].should include('уже выбрал')
      session[:reset_auth_token].should be_nil
    end
    
    it "should not allow to set auth with wrong token" do
      get :auth, id: @user.id, token: '123'
      
      response.should redirect_to(users_path)
      flash[:error].should include('Неправильный ключ')
      session[:reset_auth_token].should be_nil
    end
    
    it "should set auth_for token to session" do
      get :auth, id: @user.id, token: @user.reset_auth_token
      
      response.should be_success
      assigns(:user).should == @user
      assigns(:no_signin_form).should be_true
      session[:reset_auth_token].should == @user.reset_auth_token
    end
  
  end
  
  describe "#create" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      post :create, id: @user.id
      response.should be_forbidden
    end
    
    it "should not allow to set empty email" do
      post :create, id: @user.id, user: { 'email' => '' }
      
      response.should redirect_to(users_path)
      flash[:error].should be_present
      User.count.should == 1
    end
    
    it "should create user and send welcome mail" do
      mail = mock(:mail)
      mail.should_receive(:deliver)
      Mailer.should_receive(:welcome).with(@user, an_instance_of(User)).
        and_return(mail)
      
      post :create, id: @user.id, user: { 'email' => 'test@example.com',
                                          'name'  => 'Test',
                                          'role'  => 'Sample' }
      
      response.should redirect_to(users_path)
      flash[:notice].should be_present
      
      User.count.should == 2
      user = User.last
      user.email.should == 'test@example.com'
      user.name.should  == 'Test'
      user.role.should  == 'Sample'
      user.should_not be_confirmed
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
      
      response.should redirect_to(users_path)
      flash[:error].should be_present
      @user.reload.email.should be_present
    end
    
    it "should update user" do
      put :update, id: @user.id, user: { 'email' => 'new@example.com',
                                         'name'  => 'New',
                                         'role'  => 'Test user' }
      
      response.should redirect_to(users_path)
      @user.reload
      @user.email.should == 'new@example.com'
      @user.name.should  == 'New'
      @user.role.should  == 'Test user'
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
    
    it "should not delete current user" do
      delete :destroy, id: @user.id
      response.should be_bad_request
    end
    
  end
  
  describe "#request_auth" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
      @user.update_attribute :reset_auth_token, nil
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      post :request_auth, id: @user.id
      response.should be_forbidden
    end
    
    it "should allow to change current user auth" do
      post :request_auth, id: @user.id
      
      token = @user.reload.reset_auth_token
      token.should_not be_nil
      response.should redirect_to(auth_user_path(@user, token: token))
    end
    
    it "should allow to change auth for another user" do
      @another = Fabricate(:user)
      @another.update_attribute :reset_auth_token, nil
      
      mail = mock(:mail)
      mail.should_receive(:deliver)
      Mailer.should_receive(:change_auth).with(@user, @another).and_return(mail)
      
      post :request_auth, id: @another.id
      
      @another.reload.reset_auth_token.should_not be_nil
      response.should redirect_to(users_path)
      flash[:notice].should be_present
    end
    
  end

end

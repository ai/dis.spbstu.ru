# encoding: utf-8
require 'spec_helper'

describe SessionsController do
  
  describe "#create" do
    
    before :each do
      @fake = { 'provider' => 'fake', 'uid' => 'ivan' }
      controller.stub!(:auth_hash).and_return(@fake)
      
      @time_now = Time.parse('2000-01-01').utc
      Time.stub!(:now).and_return(@time_now)
    end
    
    it "should show error on unknow user" do
      @fake['user_info'] = { 'email' => 'ivan@examle.com' }
      @request.env['omniauth.origin'] = 'http://example.com/one'
      
      get :create, provider: 'fake'
      
      response.should redirect_to('http://example.com/one')
      assigns(:current_user).should  be_nil
      session[:session_token].should be_nil
      flash[:wrong_user].should == 'ivan@examle.com'
    end
    
    it "should signin user" do
      user = Fabricate(:user, auth_provider: 'fake', auth_uid: 'ivan')
      @request.env['omniauth.origin'] = 'http://example.com/one'
      
      get :create, provider: 'fake'
      
      response.should redirect_to('http://example.com/one')
      assigns(:current_user).should  == user
      session[:session_token].should == user.session_token
      assigns(:current_user).signin_at.utc.should == @time_now
    end
    
    it "should not save auth if session contain wrong token" do
      user = Fabricate(:user)
      session[:reset_auth_token] = '123'
      @request.env['omniauth.origin'] = 'http://example.com/one'
      
      get :create, provider: 'fake'
      
      response.should redirect_to('http://example.com/one')
      flash[:error].should be_present
      session[:reset_auth_token].should be_nil
    end
    
    it "should not save auth if it used for another user" do
      user    = Fabricate(:user)
      another = Fabricate(:user, auth_provider: 'fake', auth_uid: 'ivan')
      session[:reset_auth_token] = user.reset_auth_token
      
      get :create, provider: 'fake'
      
      response.should redirect_to(root_path)
      flash[:error].should include(another.title)
      session[:reset_auth_token].should be_nil
    end
    
    it "should save new auth if session contain reset token" do
      user = Fabricate(:user)
      session[:reset_auth_token] = user.reset_auth_token
      
      get :create, provider: 'fake'
      
      response.should redirect_to(start_users_path)
      
      user.reload
      user.auth_provider.should == 'fake'
      user.auth_uid = 'ivan'
      user.reset_auth_token.should be_nil
      session[:reset_auth_token].should be_nil
      
      assigns(:current_user).should  == user
      session[:session_token].should == user.session_token
      assigns(:current_user).signin_at.utc.should == @time_now
    end
    
    it "it should change auth if user have another auth" do
      user = Fabricate(:user, auth_provider: 'fake', auth_uid: 'john')
      session[:reset_auth_token] = user.reset_auth_token
      
      get :create, provider: 'fake'
      
      response.should redirect_to(root_path)
      
      user.reload
      user.auth_provider.should == 'fake'
      user.auth_uid.should      == 'ivan'
    end

    it "should set user name from new auth" do
      user = Fabricate(:user, auth_provider: 'fake', auth_uid: 'ivan')
      session[:reset_auth_token] = user.reset_auth_token
      @fake['user_info'] = { 'first_name' => 'Ivan' }

      get :create, provider: 'fake'

      user.reload.name.should == 'Ivan'
    end

    it "should not change user name from new auth" do
      user = Fabricate(:user, auth_provider: 'fake', auth_uid: 'i', name: 'I')
      session[:reset_auth_token] = user.reset_auth_token
      @fake['user_info'] = { 'first_name' => 'Ivan' }

      get :create, provider: 'fake'

      user.reload.name.should == 'I'
    end
    
  end
  
  describe "#failure" do
    
    it "should show error on failure" do
      @request.env['omniauth.origin'] = 'http://example.com/one'
      
      get :failure, message: 'invalid_response'
      
      response.should redirect_to('http://example.com/one')
      flash[:wrong_auth].should == 'invalid_response'
    end
    
  end
  
  describe "#destroy" do
  
    it "should logout user" do
      user = Fabricate(:user)
      old_session = user.session_token
      session[:session_token] = user.session_token
      @request.env['HTTP_REFERER'] = 'http://example.com/one'
      
      delete :destroy
      
      response.should redirect_to('http://example.com/one')
      session[:session_token].should be_nil
      user.reload.session_token.should_not == old_session
    end
  
  end

end

require 'spec_helper'

describe SessionsController do
  
  describe "#create" do
    
    before :each do
      @fake = {
        'provider'  => 'fake',
        'uid'       => 'ivan',
        'user_info' => { 'email' => 'ivan@examle.com' }
      }
      controller.stub!(:auth_hash).and_return(@fake)
      
      @time_now = Time.parse('2000-01-01').utc
      Time.stub!(:now).and_return(@time_now)
    end
    
    it "should signin user" do
      user = Fabricate(:user, auth_provider: 'fake', auth_uid: 'ivan')
      @request.env['omniauth.origin'] = 'http://example.com/one'
      
      get :create, provider: 'fake'
      
      response.should redirect_to('http://example.com/one')
      assigns(:current_user).should  == user
      session[:session_token].should == user.session_token
      assigns(:current_user).signin_at.utc.should  == @time_now
    end
    
    it "should show error on unknow user" do
      @request.env['omniauth.origin'] = 'http://example.com/one'
      
      get :create, provider: 'fake'
      
      response.should redirect_to('http://example.com/one')
      assigns(:current_user).should  be_nil
      session[:session_token].should be_nil
      flash[:wrong_user].should == 'ivan@examle.com'
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

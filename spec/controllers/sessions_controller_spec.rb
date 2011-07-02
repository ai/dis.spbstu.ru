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
      
      get :create, provider: 'fake'
      
      response.should redirect_to(root_url)
      assigns(:current_user).should  == user
      session[:session_token].should == user.session_token
      assigns(:current_user).signin_at.utc.should  == @time_now
    end
    
    it "should show error on unknow user" do
      get :create, provider: 'fake'
      
      response.should redirect_to(root_url)
      assigns(:current_user).should  be_nil
      session[:session_token].should be_nil
      flash[:wrong_user].should == 'ivan@examle.com'
    end
    
  end
  
  describe "#failure" do
    
    it "should show error on failure" do
      get :failure, message: 'invalid_response'
      
      response.should redirect_to(root_url)
      flash[:wrong_auth].should == 'invalid_response'
    end
    
  end
  
  describe "#destroy" do
  
    it "should logout user" do
      user = Fabricate(:user)
      session[:session_token] = user.session_token
      @request.env['HTTP_REFERER'] = 'http://example.com/one'
      
      post :destroy
      
      response.should redirect_to('http://example.com/one')
      session[:session_token].should be_nil
    end
  
  end

end

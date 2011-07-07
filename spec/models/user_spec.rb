# encoding: utf-8
require 'spec_helper'

describe User do
  before :each do
    @user = Fabricate(:user)
  end
  
  describe "#generate_session_token!" do
    
    it "should generate session_token on creation" do
      @user.session_token.should be_a(String)
    end
    
    it "should regenerate session_token" do
      lambda {
        @user.generate_session_token!
      }.should change(@user, :session_token)
    end
    
  end
  
  describe "#generate_reset_auth_token!" do
    
    it "should generate reset_auth_token on creation" do
      @user.reset_auth_token.should be_a(String)
    end
    
    it "should regenerate reset_auth_token" do
      lambda {
        @user.generate_reset_auth_token!
      }.should change(@user, :reset_auth_token)
    end
    
  end
  
  describe "#confirmed?" do
  
    it "should be true for users with auth_provider and auth_uid" do
      @user.should_not be_confirmed
      
      @user.auth_provider = 'fake'
      @user.should_not be_confirmed
      
      @user.auth_uid = 'ivan'
      @user.should be_confirmed
    end
    
  end
  
end

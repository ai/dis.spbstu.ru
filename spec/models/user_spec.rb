require 'spec_helper'

describe User do
  
  describe "#generate_session_token!" do
    
    it "should generate session_token on creation" do
      user = Fabricate(:user)
      user.session_token.should be_a(String)
    end
    
    it "should regenerate session_token" do
      user = Fabricate(:user)
      lambda {
        user.generate_session_token!
      }.should change(user, :session_token)
    end
    
  end
  
  describe "#confirmed?" do
    it "should be true for users with auth_provider and auth_uid" do
      user = Fabricate(:user)
      user.should_not be_confirmed
      
      user.auth_provider = 'fake'
      user.should_not be_confirmed
      
      user.auth_uid = 'ivan'
      user.should be_confirmed
    end
  end
  
end

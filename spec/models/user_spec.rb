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
  
end

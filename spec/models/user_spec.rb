# encoding: utf-8
require 'spec_helper'

describe User do
  before :each do
    @user = Fabricate(:user)
  end
  
  describe ".new_or_restore" do
    
    it "should return new user with new email" do
      user = User.new_or_restore('new@example.com')
      user.should be_new
      user.destroy
    end
    
    it "should restore deleted user by email" do
      deleted = Fabricate(:user, deleted_at: Time.now)
      user = User.new_or_restore(deleted.email)
      
      user.id.should == deleted.id
      user.should_not be_deleted
    end
    
  end
  
  describe ".undeleted" do
    
    it "should return only undeleted users" do
      del = Fabricate(:user, deleted_at: Time.now)
      
      User.undeleted.to_a.should == [@user]
    end
    
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
  
  describe "#deleted?" do
  
    it "should return true for deleted user" do
      @user.should_not be_deleted
      @user.deleted_at = Time.now
      @user.should be_deleted
    end
    
  end
  
  describe "#destroy_or_mark_as_deleted!" do
  
    it "should destroy user without edits" do
      @user.should_receive(:destroy)
      @user.destroy_or_mark_as_deleted!
    end
    
    it "should mark user with edits" do
      @time_now = Time.parse('2000-01-01').utc
      Time.stub!(:now).and_return(@time_now)
      
      content = Fabricate(:content)
      content.update_text! 'Text', @user
      
      @user.should_not_receive(:destroy!)
      @user.destroy_or_mark_as_deleted!
      
      @user.reload.should be_deleted
      @user.deleted_at.should == @time_now
    end
  
  end
  
end

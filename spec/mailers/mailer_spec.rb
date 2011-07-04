# encoding: utf-8

require 'spec_helper'

describe Mailer do
  
  before :each do
    @current = Fabricate(:user, name: 'SourceOfEvent')
    @user    = Fabricate(:user)
  end
  
  describe "layout" do
  
    it "should use user name in layout" do
      email = Mailer.welcome(@current, @user).deliver
      email.body.should include('Добрый день.')
      
      @user.name = 'Тест'
      email = Mailer.welcome(@current, @user).deliver
      email.body.should include('Добрый день, Тест.')
    end
  
  end
  
  describe "#welcome" do
  
    it "should send inviter and auth URL" do
      email = Mailer.welcome(@current, @user).deliver
      ActionMailer::Base.should have(1).delivery
      url = auth_user_path(@user, token: @user.reset_auth_token)
      email.body.should include(url)
      email.body.should include(@current.name)
    end
  
  end
  
  describe "#change_auth" do
  
    it "should send requester and auth URL" do
      email = Mailer.change_auth(@current, @user).deliver
      ActionMailer::Base.should have(1).delivery
      url = auth_user_path(@user, token: @user.reset_auth_token)
      email.body.should include(url)
      email.body.should include(@current.name)
    end
  
  end
  
end

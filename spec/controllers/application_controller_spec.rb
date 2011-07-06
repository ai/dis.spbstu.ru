# encoding: utf-8
require "spec_helper"

describe ApplicationController do

  describe "#current_user" do
    controller do
      def index
        if params[:set]
          self.current_user = User.where(email: params[:set]).first
        end
        if params[:cache]
          @current_user = User.where(email: params[:cache]).first
        end
        
        render text: current_user.email
      end
    end
  
    it "should load signed in user" do
      user = Fabricate(:user)
      session[:session_token] = user.session_token
      
      get :index
      
      assigns(:current_user).should == user
      response.body.should == user.email
    end
    
    it "should set current user" do
      user = Fabricate(:user)
      
      get :index, set: user.email
      
      assigns(:current_user).should  == user
      session[:session_token].should == user.session_token
      response.body.should == user.email
    end
    
    it "should cache current user" do
      user = Fabricate(:user)
      
      get :index, cache: user.email
      
      response.body.should == user.email
    end
  
  end

  describe "#signed_in?" do
  
    controller do
      def index
        if params[:user]
          self.current_user = User.where(email: params[:user]).first
        end
        render text: signed_in? ? 'true' : 'false'
      end
    end
  
    it "should return true if user is signed in" do
      get :index
      response.body.should == 'false'
      
      user = Fabricate(:user)
      get :index, user: user.email
      response.body.should == 'true'
    end
    
  end
  
  describe "#authenticate_user!" do
  
    controller do
      before_filter :authenticate_user!
      
      def index
        render text: 'ok'
      end
    end
    
    it "should show forbidden page for unauthenticated users" do
      get :index
      
      response.should render_template('errors/forbidden')
      response.should be_forbidden
    end
    
    it "should show forbidden page for unauthenticated users" do
      user = Fabricate(:user)
      session[:session_token] = user.session_token
      
      get :index
      
      response.body.should == 'ok'
    end
    
  end
  
end

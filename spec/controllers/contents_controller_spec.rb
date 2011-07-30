# encoding: utf-8
require 'spec_helper'

describe ContentsController do
  render_views # Проверяет, что в шаблонах нет синтаксических ошибок
  
  describe "routes" do
    
    it "should route content" do
      { get:    '/dir/page' }.should route_to(controller: 'contents',
                                              action:     'show',
                                              path:       'dir/page')
      { put:    '/dir/page' }.should route_to(controller: 'contents',
                                              action:     'update',
                                              path:       'dir/page')
      { delete: '/dir/page' }.should route_to(controller: 'contents',
                                              action:     'destroy',
                                              path:       'dir/page')
    end
    
    it "should trim last slash" do
      { get:    '/dir/page/' }.should route_to(controller: 'contents',
                                               action:     'show',
                                               path:       'dir/page')
    end
    
    it "should recognize content format" do
      { get: '/dir/page.txt' }.should route_to(controller: 'contents',
                                               action:     'show',
                                               path:       'dir/page',
                                               format:     'txt')
    end
    
    it "should route root" do
      { get:  '/' }.should route_to(       controller: 'contents',
                                           action:     'show',
                                           path:       '')
      { put:  '/' }.should route_to(       controller: 'contents',
                                           action:     'update',
                                           path:       '')
      { get:  '/edit' }.should route_to(   controller: 'contents',
                                           action:     'edit',
                                           path:       '')
      { post: '/restore' }.should route_to(controller: 'contents',
                                           action:     'restore',
                                           path:       '')
    end
    
    it "should not allow to delete root" do
      { delete: '/' }.should_not be_routable
    end
    
  end
  
  describe "#all" do
  
    it "should return all site pages" do
      b = Fabricate(:content, title: 'B')
      a = Fabricate(:content, title: 'A')
      
      get :all, format: 'json'
      
      response.should be_success
      assigns(:all).should == [a, b]
    end
  
  end
  
  describe "#show" do
    
    it "should load content" do
      content = Fabricate(:content)
      content.update_text! ''
      
      get :show, path: content.path
      
      response.should be_success
      assigns(:content).should == content
    end
    
    it "should show add first slash to path" do
      content = Fabricate(:content, path: '/path/to/page')
      content.update_text! ''
      
      get :show, path: 'path/to/page'
      
      assigns(:content).should == content
    end
    
    it "should show root page" do
      content = Fabricate(:content, path: '/')
      content.update_text! ''
      
      get :show, path: ''
      
      assigns(:content).should == content
    end
    
    it "should return 404 if content doesn't exists" do
      get :show, path: 'page/404'
      response.status.should == 404
    end
    
    it "should return 404 for deleted page" do
      content = Fabricate(:deleted_content)
      get :show, path: content.path
      response.status.should == 404
      assigns(:content).should == content
    end
    
    it "should load version of content" do
      content = Fabricate(:content)
      content.update_text! 'First'
      content.update_text! 'Current'
      
      get :show, path: content.path
      assigns(:version).should == content.versions.last
      
      get :show, path: content.path, version: 1
      assigns(:content).should == content
      assigns(:version).should == content.versions.first
      
      get :show, path: content.path, version: 2
      assigns(:version).should == content.versions.last
      
      get :show, path: content.path, version: 999
      response.status.should == 404
    end
    
  end
  
  describe "#edit" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      get :edit, path: 'page/404'
      response.should be_forbidden
    end
    
    it "should load content" do
      content = Fabricate(:content)
      
      get :edit, path: content.path
      
      response.should be_success
      assigns(:content).should == content
    end
    
    it "should show form if content doesn't exists" do
      get :edit, path: 'page/404'
      
      response.should be_success
      assigns(:content).should be_a(Content)
      assigns(:content).should be_new
      assigns(:content).path.should == '/page/404'
    end
    
    it "should show form for deleted page" do
      content = Fabricate(:deleted_content)
      
      get :edit, path: content.path
      
      response.should be_success
      assigns(:content).should == content
    end
    
  end
  
  describe "#update" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      post :update, path: 'page/404', text: 'New text'
      response.should be_forbidden
    end
    
    it "should save new pages" do
      post :update, path: 'page/404', text: 'New text'
      
      content = Content.last
      content.path.should == '/page/404'
      content.versions.last.text.should == 'New text'
    end
    
    it "should edit deleted pages" do
      content = Fabricate(:deleted_content)
      
      post :update, path: content.path, text: 'New text'
      
      content.reload
      content.versions.last.text.should == 'New text'
      response.should redirect_to(content.path)
    end
    
    it "should save previous version" do
      prev_user = Fabricate(:user)
      content   = Fabricate(:content)
      content.update_text! 'Old text', prev_user
      
      post :update, path: content.path, text: 'New text'
      
      content.reload
      content.should have(2).versions
      
      content.versions[0].version.should == 1
      content.versions[0].text.should    == 'Old text'
      content.versions[0].author.should  == prev_user
      
      content.versions[1].version.should == 2
      content.versions[1].text.should    == 'New text'
      content.versions[1].author.should  == @user
    end
    
  end
  
  describe "#destroy" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      delete :destroy, path: 'page/404'
      response.should be_forbidden
    end
    
    it "should return 404 if content doesn't exists" do
      delete :destroy, path: 'page/404'
      response.status.should == 404
    end
    
    it "should mark content as deleted" do
      content = Fabricate(:content)
      
      delete :destroy, path: content.path
      
      content.reload.should be_deleted
      flash[:notice].should be_present
      response.should redirect_to(content.path)
    end
    
  end
  
  describe "#restore" do
  
    before :each do
      @user = Fabricate(:user)
      session[:session_token] = @user.session_token
    end
    
    it "should be accessed only for users" do
      session.delete :session_token
      post :restore, path: 'page/404'
      response.should be_forbidden
    end
    
    it "should return 404 if content doesn't exists" do
      post :restore, path: 'page/404'
      response.status.should == 404
    end
    
    it "should unmark content as deleted" do
      content = Fabricate(:deleted_content)
      
      post :restore, path: content.path
      
      content.reload.should_not be_deleted
      response.should redirect_to(content.path)
    end
    
  end

end

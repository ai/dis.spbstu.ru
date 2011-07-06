# encoding: utf-8
require 'spec_helper'

describe ContentsController do
  
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
  
  describe "#show" do
    
    it "should load content" do
      content = Fabricate(:content)
      
      get :show, path: content.path
      
      response.should be_success
      assigns(:content).should == content
    end
    
    it "should show add first slash to path" do
      content = Fabricate(:content, path: '/path/to/page')
      get :show, path: 'path/to/page'
      assigns(:content).should == content
    end
    
    it "should show root page" do
      content = Fabricate(:content, path: '/')
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
    end
    
    it "should load version of content" do
      content = Fabricate(:content, text: 'First')
      content.text = 'Current'
      content.save
      
      get :show, path: content.path
      assigns(:version).should == content
      
      get :show, path: content.path, version: 1
      assigns(:content).should == content
      assigns(:version).should == content.versions.first
      
      get :show, path: content.path, version: 2
      assigns(:version).should == content
      
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
      post :update, path: 'page/404', content: { 'text' => 'New text' }
      response.should be_forbidden
    end
    
    it "should save content" do
      content = Fabricate(:content)
      
      post :update, path: content.path, content: { 'text' => 'New text' }
      
      content.reload
      content.text.should   == 'New text'
      content.author.should == @user
      response.should redirect_to(content.path)
    end
    
    it "should save previous version" do
      prev_user = Fabricate(:user)
      content   = Fabricate(:content, text: 'Old text', author: prev_user)
      
      post :update, path: content.path, content: { 'text' => 'New text' }
      
      content.reload
      content.version.should  == 2
      
      previous = content.versions[0]
      previous.version.should == 1
      previous.text.should    == 'Old text'
      previous.author.should  == prev_user
    end
    
    it "should show form if content doesn't exists" do
      post :update, path: 'page/404', content: { 'text' => 'New text' }
      
      content = Content.last
      content.path.should == '/page/404'
      content.text.should == 'New text'
    end
    
    it "should show form for deleted page" do
      content = Fabricate(:deleted_content)
      
      post :update, path: content.path, content: { 'text' => 'New text' }
      
      content.reload.text.should == 'New text'
      response.should redirect_to(content.path)
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
      flash[:notice].should_not be_blank
      response.should redirect_to(root_path)
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

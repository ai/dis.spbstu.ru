# encoding: utf-8
require 'spec_helper'

describe ApplicationHelper do
  
  describe "edit_content_path" do
  
    it "should return path to edit page by model" do
      content = Fabricate(:content, path: '/long/path')
      helper.edit_content_path(content).should == '/long/path/edit'
      
      root = Fabricate(:content, path: '/')
      helper.edit_content_path(root).should == '/edit'
    end
    
    it "should return path to edit page by string" do
      helper.edit_content_path('/long/path').should  == '/long/path/edit'
      helper.edit_content_path('/long/path/').should == '/long/path/edit'
      helper.edit_content_path('/').should == '/edit'
    end
  
  end
  
end

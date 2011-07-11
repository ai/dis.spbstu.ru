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
  
  describe "add_attr" do
  
    it "should add value for new attribute" do
      attrs = { name: 't' }
      helper.add_attr(attrs, b: '2')
      attrs.should == { name: 't', b: '2' }
    end
  
    it "should add value for exists attribute" do
      attrs = { a: 't' }
      helper.add_attr(attrs, a: '1', b: '2')
      attrs.should == { a: 't 1', b: '2' }
    end
  
  end
  
  describe "go_button" do
  
    it "should return go button" do
      helper.go_button('Button').should ==
        '<a class="go-button" href="#"><span>Button</span>' +
          '<div class="crop"><div class="arrow"><div></div></div></div></a>'
    end
  
    it "should allow to set attribute" do
      helper.go_button('Button', role: 'add').should ==
        '<a class="go-button" href="#" role="add"><span>Button</span>' +
          '<div class="crop"><div class="arrow"><div></div></div></div></a>'
    end
  
    it "should allow to set URL" do
      helper.go_button('Button', href: '/path').should ==
        '<a class="go-button" href="/path"><span>Button</span>' +
          '<div class="crop"><div class="arrow"><div></div></div></div></a>'
    end
  
    it "should allow to set class" do
      helper.go_button('Button', class: 'add').should ==
        '<a class="add go-button" href="#"><span>Button</span>' +
          '<div class="crop"><div class="arrow"><div></div></div></div></a>'
    end
  
  end
  
  describe "button" do
  
    it "should return styled button" do
      helper.button('Button').should ==
        '<a class="styled-button" href="#"><span>Button</span></a>'
    end
  
    it "should allow to set attribute" do
      helper.button('Button', role: 'add').should ==
        '<a class="styled-button" href="#" role="add"><span>Button</span></a>'
    end
  
    it "should allow to set URL" do
      helper.button('Button', href: '/path').should ==
        '<a class="styled-button" href="/path"><span>Button</span></a>'
    end
  
    it "should allow to set class" do
      helper.button('Button', class: 'add').should ==
        '<a class="add styled-button" href="#"><span>Button</span></a>'
    end
  
  end
  
  describe "submit_button" do
  
    it "should return submit styled button" do
      helper.submit_button('Button').should ==
        '<a class="styled-button" href="#" role="submit">' +
          '<span>Button</span></a>'
    end
  
    it "should allow to set role" do
      helper.submit_button('Button', role: 'add').should ==
        '<a class="styled-button" href="#" role="add submit">' +
          '<span>Button</span></a>'
    end
  
  end
  
  describe "shadowed_button" do
  
    it "should return styled button with shadow wrap" do
      helper.shadowed_button('Button').should ==
        '<div class="shadowed-button"><span>Button</span>' +
          '<a class="styled-button" href="#"><span>Button</span></a></div>'
    end
    
    it "should allow to set button options" do
      helper.shadowed_button('Button', class: 'add').should ==
        '<div class="shadowed-button"><span>Button</span>' +
          '<a class="add styled-button" href="#"><span>Button</span></a></div>'
    end
    
  end
  
end

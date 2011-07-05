require 'spec_helper'

describe ApplicationHelper do
  
  it "should return path to edit page" do
    content = Fabricate(:content, path: '/long/path')
    helper.edit_content_path(content).should == '/long/path/edit'
    
    root = Fabricate(:content, path: '/')
    helper.edit_content_path(root).should == '/edit'
  end
  
end

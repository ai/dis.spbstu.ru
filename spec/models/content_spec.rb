require 'spec_helper'

describe Content do
  
  describe "#by_path" do
    
    it "should return content by path" do
      content = Fabricate(:content)
      Content.by_path(content.path).should == content
    end
    
    it "should raise 404 when path is not found" do
      lambda {
        Content.by_path('page/404')
      }.should raise_error(Mongoid::Errors::DocumentNotFound)
    end
    
  end
  
  describe "#by_path_without_deleted" do
    
    it "should return content by path" do
      content = Fabricate(:content)
      Content.by_path_without_deleted(content.path).should == content
    end
    
    it "should not return deleted content" do
      content = Fabricate(:deleted_content)
      lambda {
        Content.by_path_without_deleted(content.path)
      }.should raise_error(Mongoid::Errors::DocumentNotFound)
    end
    
    it "should raise 404 when path is not found" do
      lambda {
        Content.by_path_without_deleted('page/404')
      }.should raise_error(Mongoid::Errors::DocumentNotFound)
    end
    
  end
  
  describe "#deleted?" do
  
    it "should return true for delete content" do
      content = Fabricate(:content)
      content.should_not be_deleted
      content.deleted_at = Time.now
      content.should be_deleted
    end
    
  end
  
  describe "#mark_as_deleted" do
    
    it "should mark content as deleted" do
      time_now = Time.parse('2000-01-01').utc
      Time.stub!(:now).and_return(time_now)
      
      content = Fabricate(:content)
      
      lambda {
        content.mark_as_deleted!
      }.should change(content, :deleted_at).from(nil).to(time_now)
      content.should_not be_changed
    end
    
  end
  
  describe "#restore" do
    
    it "should unmark content as deleted" do
      content = Fabricate(:deleted_content)
      
      lambda {
        content.restore!
      }.should change(content, :deleted_at).from(content.deleted_at).to(nil)
      content.should_not be_changed
    end
    
  end
  
  describe "#get_version" do
  
    before :each do
      @content = Fabricate(:content, text: 'First')
      @content.text = 'Current'
      @content.save
    end
    
    it "should return old version" do
      @content.get_version(1).should == @content.versions[0]
      @content.get_version(1).version.should == 1
    end
    
    it "should receive string as version number" do
      @content.get_version('1').should == @content.versions[0]
    end
    
    it "should return current version" do
      @content.get_version(2).should == @content
    end
    
    it "should return current version, when version is nil" do
      @content.get_version(nil).should == @content
    end
    
    it "should raise 404, when it can find version" do
      lambda {
        @content.get_version(999)
      }.should raise_error(Mongoid::Errors::DocumentNotFound)
    end
  
  end
  
end

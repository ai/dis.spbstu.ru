# encoding: utf-8
require 'spec_helper'

describe Content do
  
  describe ".by_path" do
    
    it "should return content by path" do
      content = Fabricate(:content)
      Content.by_path(content.path).should == content
    end
    
    it "should raise 404 when path is not found" do
      Content.should_receive(:raise404)
      Content.by_path('page/404')
    end
    
  end
  
  describe ".raise404" do
    
    it "should raise error" do
      lambda {
        Content.raise404
      }.should raise_error(Mongoid::Errors::DocumentNotFound)
    end
    
  end
  
  describe "#deleted?" do
  
    it "should return true for deleted content" do
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
  
  describe "#update_text!" do
  
    before :each do
      @content = Fabricate(:content)
      @author  = Fabricate(:user)
      @another = Fabricate(:user)
    end
    
    it "should create new version" do
      @content.versions.should be_empty
      
      @content.update_text! 'One', @author
      @content.should have(1).versions
      @content.versions.first.version       == 1
      @content.versions.first.text.should   == 'One'
      @content.versions.first.author.should == @author
      
      @content.update_text! 'Two', @another
      @content.should have(2).versions
      @content.versions.first.version    == 2
      @content.versions[1].text.should   == 'Two'
      @content.versions[1].author.should == @another
    end
    
    it "should create new version without author" do
      @content.update_text! 'Text'
      @content.versions.first.text.should == 'Text'
      @content.versions.first.author.should be_nil
    end
    
    it "should not create new version with same text" do
      @content.update_text! 'Text', @author
      @content.should have(1).versions
      
      @content.update_text! 'Text', @another
      @content.should have(1).versions
    end
    
    it "should update updated_at" do
      time_now = Time.parse('2000-01-01').utc
      Time.stub!(:now).and_return(time_now)
      
      @content.update_text! 'Text'
      @content.updated_at.utc.should == time_now
    end
    
  end
  
  describe "#version" do
  
    before :each do
      @content = Fabricate(:content)
      @content.update_text! 'First'
      @content.update_text! 'Current'
    end
    
    it "should return old version" do
      @content.version(1).should == @content.versions.first
      @content.version(1).version.should == 1
    end
    
    it "should receive string as version number" do
      @content.version('1').should == @content.versions.first
    end
    
    it "should return last version" do
      @content.version(2).should == @content.versions.last
    end
    
    it "should return last version, when version is nil" do
      @content.version(nil).should == @content.versions.last
    end
    
    it "should return last version, when version is passed" do
      @content.version.should == @content.versions.last
    end
    
    it "should raise 404, when it is no versions" do
      Content.should_receive(:raise404)
      content = Fabricate(:content)
      content.version
    end
    
    it "should raise 404, when it can not find version" do
      Content.should_receive(:raise404)
      @content.version(999)
    end
  
  end
  
  describe "#title" do
    
    it "should cache title from text" do
      content = Fabricate(:content)
      content.update_text! "Заголовок: Один"
      content.reload.title.should == 'Один'
      
      content.update_text! 'Заголовок: Два'
      content.reload.title.should == 'Два'
    end
    
  end
  
  describe "#root?" do
    
    it "should return true for root page" do
      root   = Fabricate(:content, path: '/')
      common = Fabricate(:content, path: '/common')
      
      root.should be_root
      common.should_not be_root
    end
    
  end
  
  describe "#as_json" do
    
    it "should return only title and path in JSON" do
      a = Fabricate(:content, path: '/a')
      b = Fabricate(:content, path: '/b')
      a.update_text! "Заголовок: A\nabc"
      b.update_text! "Заголовок: B\ncba"
      
      [a, b].to_json.should == '[{"path":"/a","title":"A"},' +
                                '{"path":"/b","title":"B"}]'
    end
    
    it "should set title for root" do
      a = Fabricate(:content, path: '/')
      a.as_json.should == { path: '/', title: 'Главная страница' }
    end
    
  end
  
end

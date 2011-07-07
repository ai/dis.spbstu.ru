# encoding: utf-8
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
  
  describe "#html" do
  
    it "should render HTML from Markdown" do
      content = Fabricate(:content, text: '*Warning*')
      content.html.should == "<p><em>Warning</em></p>\n"
      
      content.text = "**New** value"
      content.html.should == "<p><strong>New</strong> value</p>\n"
    end
    
    it "should render page without text" do
      content = Fabricate(:content, text: nil)
      content.html.should == ''
    end
  
  end
  
  describe "#render" do
    
    it "should cache rendering" do
      content = Fabricate(:content, text: 'First')
      content.should_receive(:render_html).twice
      
      content.html
      content.path = 'path/new'
      content.html
      
      content.text = 'Second'
      content.html
      content.html
      
      content.text = 'Third'
    end
    
  end
  
  describe "#load_meta" do
    
    it "should get title, keywords and description from text" do
      content = Fabricate(:content, text: "Текст")
      content.title.should       be_nil
      content.description.should be_nil
      content.keywords.should    be_nil
      
      content.text = " \n" +
                     "Заголовок: Имя \n" +
                     "Описание:  Тест\n" +
                     "\n \n" +
                     "Ключевые слова: один, два" +
                     "\n" +
                     "Текст\nстатьи"
      content.title.should       == 'Имя'
      content.description.should == 'Тест'
      content.keywords.should    == 'один, два'
      content.html.should        == "<p>Текст\nстатьи</p>\n"
      
      content.text = 'Текст'
      content.title.should       be_nil
      content.description.should be_nil
      content.keywords.should    be_nil
      content.html.should        == "<p>Текст</p>\n"
    end
    
    it "should cache meta" do
      content = Fabricate(:content)
      content.should_receive(:parse_meta).twice
      content.should_not_receive(:render_html)
      
      content.text = "Заголовок: Тест\nТекст статьи"
      content.title
      content.keywords
      content.keywords
      
      content.text = ''
      content.title
      content.title
    end
    
  end
  
  describe "#title" do
    
    it "should cache title from text" do
      content = Fabricate(:content, text: "Заголовок: Один")
      content.reload.title.should == 'Один'
      
      content.text = 'Заголовок: Два'
      content.save
      content.reload.title.should == 'Два'
    end
    
  end
  
end

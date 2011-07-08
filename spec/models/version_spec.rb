# encoding: utf-8
require 'spec_helper'

describe Version do
  
  describe "#version" do
  
    it "should iterate version number" do
      content = Fabricate(:content)
      content.update_text! 'One'
      content.versions.last.version.should == 1
      content.update_text! 'Two'
      content.versions.last.version.should == 2
      
      another = Fabricate(:content)
      another.update_text! 'Один'
      another.versions.last.version.should == 1
    end
  
  end
  
  describe "#last?" do
  
    it "should return true for last version of content" do
      content = Fabricate(:content)
      content.update_text! 'One'
      content.versions[0].should be_last
      
      content.update_text! 'Two'
      content.versions[0].should_not be_last
      content.versions[1].should be_last
    end
  
  end
  
  describe "#html" do
  
    it "should render HTML from Markdown" do
      content = Fabricate(:content)
      content.update_text! '*Warning*'
      content.version.html.should == "<p><em>Warning</em></p>\n"
      
      content.update_text! '**New** value'
      content.version.html.should == "<p><strong>New</strong> value</p>\n"
    end
  
  end
  
  describe "#render_html" do
    
    it "should cache rendering" do
      content = Fabricate(:content)
      content.update_text! 'First'
      content.version.should_receive(:render_html).once
      
      content.version.html
      content.version.html
    end
    
  end
  
  describe "#parse_meta" do
    
    it "should get title, keywords and description from text" do
      content = Fabricate(:content)
      
      content.update_text! 'Текст'
      content.version.title.should       be_nil
      content.version.description.should be_nil
      content.version.keywords.should    be_nil
      
      content.update_text! " \n" +
                           "Заголовок: Имя \n" +
                           "Описание:  Тест\n" +
                           "\n \n" +
                           "Ключевые слова: один, два" +
                           "\n" +
                           "Текст\nстатьи"
      content.version.title.should       == 'Имя'
      content.version.description.should == 'Тест'
      content.version.keywords.should    == 'один, два'
      content.version.html.should        == "<p>Текст\nстатьи</p>\n"
      
      content.update_text! 'Текст'
      content.version.title.should       be_nil
      content.version.description.should be_nil
      content.version.keywords.should    be_nil
      content.version.html.should        == "<p>Текст</p>\n"
      
      content.update_text! 'Заголовок: Имя'
      content.version.title.should       == 'Имя'
      content.version.description.should be_nil
      content.version.keywords.should    be_nil
      content.version.html.should        == ''
    end
    
    it "should cache meta" do
      content = Fabricate(:content)
      content.update_text! "Заголовок: Тест\nТекст статьи"
      content.reload
      content.version.should_receive(:parse_meta).once
      content.version.should_not_receive(:render_html)
      
      content.version.title
      content.version.title
      content.version.keywords
      content.version.keywords
    end
    
  end
  
end

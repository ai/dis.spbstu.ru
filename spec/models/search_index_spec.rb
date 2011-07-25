# encoding: utf-8
require 'spec_helper'

describe SearchIndex do
  before :each do
    @index = SearchIndex.new
    @one   = Fabricate(:content, title: 'ac yz')
    @two   = Fabricate(:content, title: 'abz')
    @one_result = SearchResult.new(@one.id, @one.title)
    @two_result = SearchResult.new(@two.id, @two.title)
  end
  
  describe ".search" do
    before :each do
      @index.add(@one)
      @index.add(@two)
    end
    
    it "should search by one word" do
      @index.search('a').should == [@two_result, @one_result]
    end
    
    it "should search by two word" do
      @index.search('a y').should == [@one_result]
    end
    
  end
  
  describe ".add" do
    
    it "should add content to index" do
      
      @index.add(@one)
      @index.index.should == {
        'a'  => [ @one_result ],
        'ac' => [ @one_result ],
        'y'  => [ @one_result ],
        'yz' => [ @one_result ],
      }
      
      @index.add(@two)
      @index.index.should == {
        'a'   => [ @one_result, @two_result ],
        'ac'  => [ @one_result ],
        'y'   => [ @one_result ],
        'yz'  => [ @one_result ],
        'ab'  => [ @two_result ],
        'abz' => [ @two_result ],
      }
    end
    
  end
  
  describe ".remove" do
    
    it "should remove content from index" do
      @index.add(@one)
      @index.add(@two)
      
      @index.remove(@one)
      @index.index.should == {
        'a'   => [ @two_result ],
        'ab'  => [ @two_result ],
        'abz' => [ @two_result ],
      }
    end
    
  end
  
end

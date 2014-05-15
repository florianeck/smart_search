# -*- encoding : utf-8 -*-
require "test_helper"
class SmartSearchTest < Test::Unit::TestCase

  def test_simple_search_tags_should_be_saved
    office_name = "Office1"
    office = Office.create(:name => office_name)
    
    Office.enable_similarity = false
    
    assert_equal office, Office.find_by_tags(office_name).first
  end
  
  def test_search_tags_should_cross_reference
    
    office_name = "Office2"
    
    office  = Office.create(:name => office_name)
    user    = User.create(:first_name => "My", :last_name => "User", :office_id => office.id)
    
    assert_equal user, User.find_by_tags("My User").first
    assert_equal user, User.find_by_tags(office_name).first
    
    # test that all is linked correctly
    assert_equal user.office, office
    assert_equal user.office_id, office.id
    assert_equal 1, office.users.size
    
    # test for loading user names to office
    office.save
    
    assert_equal office, Office.find_by_tags("My User").first
    
  end     
  
  def test_should_use_default_conditions
    office_id_ok  = 4
    office_id_nok = 5
    
    User.smart_search :on => [:full_name], :conditions => "office_id <> #{office_id_nok}", :force => true
    User.enable_similarity = false
    
    user    = User.create(:first_name => "Unknown", :last_name => "User", :office_id => office_id_nok)
    user    = User.create(:first_name => "Public", :last_name => "User", :office_id => office_id_ok)
    
    assert_equal User.find_by_tags("unknown").size, 0
    assert_equal User.find_by_tags("public").size, 1
  end
  
  def test_should_use_default_order_and_order_should_be_overwriteable
    User.smart_search :on => [:full_name], :order => :first_name, :force => true
    User.enable_similarity = false
    
    user_c    = User.create(:first_name => "C", :last_name => "Test1")
    user_a    = User.create(:first_name => "A", :last_name => "Test3")
    user_b    = User.create(:first_name => "B", :last_name => "Test2")
    
    
    assert_equal  user_a, User.find_by_tags("test").first
    assert_equal  user_c, User.find_by_tags("test").last
    
    assert_equal  user_c, User.find_by_tags("test", :order => :last_name).first
    assert_equal  user_a, User.find_by_tags("test", :order => :last_name).last
  end
  
  def test_search_tags_should_work_with_array_of_strings   
    User.smart_search :on => %w(first_name last_name office.name), :force => true
    o = Office.create(:name => "Neandertal")
    u = User.create(:first_name => "Homo", :last_name => "Sapiens", :office_id => o.id)
    
  end  
  
  
  def test_should_create_search_history
    User.find_by_tags("XXXYYY")

    assert_not_equal 0, SmartSearchHistory.where(:query => "XXXYYY").size
  end  
  
  
end  
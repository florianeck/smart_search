# -*- encoding : utf-8 -*-
require "test_helper"
class SmartSearchTest < Test::Unit::TestCase

  def test_simple_search_tags_should_be_saved
    office_name = "Office1"
    office = Office.create(:name => office_name)
    
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
  
  
  
  
end  
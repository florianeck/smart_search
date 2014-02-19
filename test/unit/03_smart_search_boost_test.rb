# -*- encoding : utf-8 -*-
require "test_helper"
class SmartSearchBoostTest < Test::Unit::TestCase

  def test_boost_search_index_cols_should_be_created
    SmartSearchTag.connection.execute("TRUNCATE #{SmartSearchTag.table_name}")
    Customer.smart_search :on => [
      {:field_name => :first_name, :boost => 1},
      {:field_name => :last_name, :boost => 2},
      {:field_name => "user.full_name", :boost => 0.5},
      ], :force => true
    
    user = User.create(:first_name => "Pi", :last_name => "Pa")
    
    Customer.create(:first_name => "Lorem", :last_name => "Ipsum", :user_id => user.id)
    
    assert_equal 1, SmartSearchTag.where(:field_name => "first_name", :boost => 1).count
    assert_equal 1, SmartSearchTag.where(:field_name => "last_name", :boost => 2).count
    assert_equal 1, SmartSearchTag.where(:field_name => "user.full_name", :boost => 0.5).count
  end
  
  def test_boost_search__results_should_order_by_score
    Customer.smart_search :on => [
      {:field_name => :first_name, :boost => 1},
      {:field_name => :last_name, :boost => 2},
      {:field_name => "user.full_name", :boost => 0.5},
      ], :force => true
    
    user = User.create(:first_name => "Rudi", :last_name => "Piff")
    
    c1 = Customer.create(:first_name => "Rudi", :last_name => "Rolle", :user_id => user.id)
    c2 = Customer.create(:first_name => "Rolle", :last_name => "Rudi", :user_id => user.id)
    c3 = Customer.create(:first_name => "Jackie", :last_name => "Brown", :user_id => user.id)
    
    results = Customer.find_by_tags("Rudi")
    
    assert_equal c1, results[1]
    assert_equal c2, results[0]
    assert_equal c3, results[2]
  end
  
  
  def test_same_boost_search_index_cols_should_be_grouped
    
    Customer.smart_search :on => [
      {:field_name => :first_name, :boost => 2},
      {:field_name => :last_name, :boost => 2},
      {:field_name => "user.full_name", :boost => 0.5},
      ], :force => true
    
    user = User.create(:first_name => "Pipi", :last_name => "Papa")
    
    customer = Customer.create(:first_name => "Lorem", :last_name => "Ipsum", :user_id => user.id)
    
    assert_equal 2, SmartSearchTag.where(:table_name => Customer.table_name, :entry_id => customer.id).count
  end
 
  
  
end  
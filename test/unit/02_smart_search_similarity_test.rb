# -*- encoding : utf-8 -*-
require "test_helper"
class SmartSearchSimilartyTest < Test::Unit::TestCase
  
  def test_similarity_should_load_from_file
    testfile_1 = File.expand_path("../../test_document_one_line.txt", __FILE__)
    testfile_2 = File.expand_path("../../test_document_multi_line.txt", __FILE__)
    SmartSimilarity.connection.execute "Truncate table #{SmartSimilarity.table_name}"
    
    assert_equal 0, SmartSimilarity.count
    SmartSimilarity.load_file(testfile_2)
    new_count = SmartSimilarity.count
    assert_not_equal 0, new_count
    
    SmartSimilarity.load_file(testfile_1)
    assert_not_equal new_count, SmartSimilarity.count
  end
  
  def test_similarity_should_load_from_url
    count = SmartSimilarity.count
    SmartSimilarity.load_url("https://github.com/florianeck/smart_search")
    assert_not_equal count, SmartSimilarity.count
  end
  
  def test_similarity_should_load_from_history
    count = SmartSimilarity.count
    User.find_by_tags("this is history now")
    SmartSimilarity.load_from_query_history
    assert_not_equal count, SmartSimilarity.count
  end      
  
end  
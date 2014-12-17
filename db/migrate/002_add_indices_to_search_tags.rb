class AddIndicesToSearchTags < ActiveRecord::Migration
  
  add_index :smart_search_tags, :entry_id
  
end  
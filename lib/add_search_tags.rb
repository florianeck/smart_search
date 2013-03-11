# -*- encoding : utf-8 -*-
class AddSearchTags < ActiveRecord::Migration
 
  def self.add_to_table(table_name)
    add_column table_name, :search_tags, :text
  end  
  
end

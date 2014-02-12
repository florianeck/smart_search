# -*- encoding : utf-8 -*-
require 'rubygems'
require 'bundler'
require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_model'

require "smart_search"
require "smart_search/smart_search_engine"
require "add_search_tags"


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :office_id
      t.date    :birthday
      t.text    :search_tags
      t.timestamps
    end
    
    create_table :customers do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :user_id
      t.date    :birthday
      t.text    :search_tags
      t.timestamps
    end
    
    create_table  :offices do |t|  
      t.string  :name
      t.text    :search_tags
      t.timestamps
    end
    
    create_table "smart_search_histories", :id => false, :force => true do |t|
      t.string "query"
    end

    create_table "smart_search_ignore_words", :id => false, :force => true do |t|
      t.string "word"
      t.string "locale"
      t.string "group"
    end

    add_index "smart_search_ignore_words", ["locale"], :name => "index_smart_search_ignore_words_on_locale"

    create_table "smart_search_similarities", :id => false, :force => true do |t|
      t.string  "phrase"
      t.text    "similarities"
      t.integer "count",        :default => 0
      t.string  "ind"
    end

    add_index "smart_search_similarities", ["ind"], :name => "index_smart_search_similarities_on_ind"

    create_table "smart_search_tags", :id => false, :force => true do |t|
      t.string  "table_name"
      t.integer "entry_id"
      t.text    "search_tags"
      t.decimal "boost",       :precision => 10, :scale => 2, :default => 1.0
    end
      
  end  
# 
# def drop_db
#   ActiveRecord::Base.connection.tables.each do |table|
#     ActiveRecord::Base.connection.drop_table(table)
#   end
# end
# 
class User < ActiveRecord::Base
  
  belongs_to :office, :class_name => "Office", :foreign_key => "office_id"
  
  smart_search :on => [:full_name, 'office.name']
  self.enable_similarity = false
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end  
end

class Customer < ActiveRecord::Base
  smart_search :on => [:first_name, :last_name, 'user.full_name', 'user.office.name', :birthday]
  self.enable_similarity = false
  
  def user
    User.find(self.user_id)
  end  
  
end        

# This one has not included smart-search yet
class Office < ActiveRecord::Base
  smart_search :on => [:name, :user_names]
  self.enable_similarity = false
  
  def user_names
    self.users.map {|u| u.full_name }.join(" ")
  end
  
  def users
    User.find_all_by_office_id(self.id)
  end    
end  

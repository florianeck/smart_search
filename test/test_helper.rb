# -*- encoding : utf-8 -*-
require 'rubygems'
require 'bundler'
require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_model'

require "smart_search"
require "smart_search/smart_search_engine"


ActiveRecord::Base.establish_connection(:adapter => "mysql2", :database => "smart_search_test")

  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :office_id
      t.date    :birthday
      t.timestamps
    end
    
    create_table :customers do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :user_id
      t.date    :birthday
      t.timestamps
    end
    
    create_table  :offices do |t|  
      t.string  :name
      t.timestamps
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
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end  
end

class Customer < ActiveRecord::Base
  smart_search :on => [:first_name, :last_name, 'user.full_name', 'user.office.name', :birthday]
  
  def user
    User.find(self.user_id)
  end  
  
end        

# This one has not included smart-search yet
class Office < ActiveRecord::Base
  smart_search :on => [:name, :user_names]
  
  def user_names
    self.users.map {|u| u.full_name }.join(" ")
  end
  
  def users
    User.find_all_by_office_id(self.id)
  end    
end  

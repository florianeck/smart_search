require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_model'

require "smart_search"
require "add_search_tags"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :office_id
      t.date    :birthday
      t.text    :search_tags
    end
    
    create_table :customers do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :user_id
      t.date    :birthday
      t.text    :search_tags
    end
    
    create_table  :offices do |t|  
      t.string  :name
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
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  smart_search :on => [:first_name, :last_name, 'user.full_name', 'user.office.name', :birthday]
end        

class Office < ActiveRecord::Base
  has_many :users, :class_name => "User", :foreign_key => "office_id"
  
  smart_search :on => [:name, :user_names]
  
  def user_names
    self.users.map {|u| u.full_name }.join(" ")
  end  
end  
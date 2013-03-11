# -*- encoding : utf-8 -*-
require "smart_search"
require "add_search_tags"

module SmartSearch
  
  def self.included(base)
    base.extend ClassMethods
  end  
  
  module ClassMethods
    def smart_search(options = {:on => [], :conditions => nil, :group => nil, :order => "created_at"})
      # Check if search_tags exists
      unless is_smart_search?
        cattr_accessor :condition_default, :group_default, :tags, :order 
        send :include, InstanceMethods
        if self.column_names.index("search_tags").nil?
          ::AddSearchTags.add_to_table(self.table_name)
        end
          self.send(:before_save, :create_search_tags)

          # options zuweisen
          if options[:conditions].is_a?(String) && !options[:conditions].blank?
            self.condition_default = options[:conditions]
          elsif !options[:conditions].nil?
            raise ArgumentError, ":conditions must be a valid SQL Query"  
          end
          
          if self.column_names.include?("created_at")
            self.order = options[:order] || "created_at"
          else  
            self.order = options[:order] || "id"
          end  

          if options[:group].is_a?(String) && !options[:group].blank?
            self.group_default = options[:group]
          elsif !options[:group].nil?
            raise ArgumentError, ":group must be a valid SQL Query"  
          end

          self.tags = options[:on] || []
      end
    end
    
    def is_smart_search?
      self.included_modules.include?(InstanceMethods)
    end
    
    def result_template_path
      "/smart/search/results/#{self.name.split("::").last.underscore}"
    end  
    
    def find_by_tags(tags = "", conditions = {}, group_by = nil)
      if self.is_smart_search?
        tags = tags.split(" ")
        
        # Fallback for Empty String
        tags << "#" if tags.empty?
        
        tags.map! {|t| "search_tags LIKE '%#{t.downcase}%'"}
      
        if self.condition_default
          default_cond = "#{self.condition_default} AND"
        else
          default_cond = ""
        end    
      
        sql = "SELECT * FROM #{self.table_name} WHERE #{default_cond} (#{tags.join(' AND ')})"
        if conditions.nil?
          sql << ""
        elsif conditions.is_a?(String)
          sql << " AND #{conditions} "
        else  
          condi = ""
          conditions.each do |field, value|
            case value
              when true
                value = 1
              when false 
                value = 0
            end
            if value.is_a?(String) || value.is_a?(Numeric)     
              value = "'#{value}'" 
              condi << " AND #{field.to_s} = #{value}"
            elsif value.is_a?(Array)  
              condi << " AND #{field.to_s} IN (#{value.join(",")})"
            end  
          
          end  
          sql << " #{condi}"
        end
        if !group_by.nil?
          sql << " GROUP BY #{group_by}"
        elsif self.group_default
          sql << " GROUP BY #{self.group_default}"
        end
        
        if !self.order.blank?
          sql << " ORDER BY #{self.order}"
        end  
        
        puts sql
        self.find_by_sql(sql)
      else                      
        raise "#{self.inspect} is not a SmartSearch"
      end  
    end
    
    def set_search_index
      s = self.all.size.to_f
      self.all.each_with_index do |a, i|
        a.create_search_tags
        a.send(:update_without_callbacks)
        done = ((i+1).to_f/s)*100
        printf "Set search index for #{self.name}: #{done}%%                  \r"
      end  
    end  
         
  end  
  
  module InstanceMethods
    
    def result_template_path
      self.class.result_template_path
    end  
    
    def create_search_tags
      tags = []
      self.class.tags.each do |tag|
        if tag.is_a?(Symbol)
          tags << self.send(tag) rescue ""
        elsif tag.is_a?(String)
          tag_methods = tag.split(".")  
          tagx = self.send(tag_methods[0])
          tag_methods[1..-1].each do |x|
            tagx = tagx.send(x) rescue ""
          end
          tags << tagx  
        end  
      end
      searchtags = tags.join(" ").split(" ")  
      searchtags = searchtags.uniq.join(" ")
      search_tags_min = searchtags.gsub(" ", "").downcase
      
      self.search_tags = "#{searchtags.downcase}"
    end  
    
  end    
        

end


ActiveRecord::Base.send(:include, SmartSearch)
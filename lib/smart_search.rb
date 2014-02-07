# -*- encoding : utf-8 -*-
require "smart_search"
require "smart_similarity"
require "smart_search_history"
require "add_search_tags"

module SmartSearch
  
  def self.included(base)
    base.extend ClassMethods
  end  
  
  module ClassMethods
    def smart_search(options = {:on => [], :conditions => nil, :group => nil, :order => "created_at", :force => false})
      if table_exists?
        # Check if search_tags exists
        if !is_smart_search? || options[:force] == true
          
          cattr_accessor :condition_default, :group_default, :tags, :order_default, :enable_similarity
          send :include, InstanceMethods
          if self.column_names.index("search_tags").nil?
            ::AddSearchTags.add_to_table(self.table_name)
          end
            self.send(:before_save, :create_search_tags)
            
            self.enable_similarity = true
            
            # options zuweisen
            if options[:conditions].is_a?(String) && !options[:conditions].blank?
              self.condition_default = options[:conditions]
            elsif !options[:conditions].nil?
              raise ArgumentError, ":conditions must be a valid SQL Query"  
            else
              self.condition_default = nil
            end  
          
            if self.column_names.include?("created_at")
              self.order_default = options[:order] || "created_at"
            else  
              self.order_default = options[:order] || "id"
            end  

            self.tags = options[:on] || []
        end
      end  
    end
    
    def is_smart_search?
      self.included_modules.include?(InstanceMethods)
    end
    
    def result_template_path
      "/search/results/#{self.name.split("::").last.underscore}"
    end  
    
    def find_by_tags(tags = "", options = {})
      if self.is_smart_search?
        
        # Save Data for similarity analysis
        if tags.size > 3
          self.connection.execute("INSERT INTO `#{::SmartSearchHistory.table_name}` (`query`) VALUES ('#{tags.gsub(/[^a-zA-ZäöüÖÄÜß\ ]/, '')}');")
        end  
        
        tags = tags.split(" ")
        
        # Fallback for Empty String
        tags << "#" if tags.empty?
        
        # Similarity
        if self.enable_similarity == true
          tags.map! do |t|   
            similars = SmartSimilarity.similars(t).join("|")
          end  
        else
          tags.map! {|t| "search_tags REGEXP '#{similars}'"}
        end  
        
        
        results =  self.where("(#{tags.join(' AND ')})")
        
        if options[:conditions]
          results = results.where(options[:conditions])
        end
        
        if !self.condition_default.blank?
          results = results.where(self.condition_default)
        end  
        
        if options[:group]
          results = results.group(options[:group])
        end  
        
        if options[:order]
          results = results.order(options[:order])
        else
          results = results.order(self.order_default)
        end    
                
        return results
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
    
    # Load all search tags for this table into similarity index
    def set_similarity_index
      
      search_tags_list = self.connection.select_all("SELECT search_tags from #{self.table_name}").map {|r| r["search_tags"]}
      
      SmartSimilarity.create_from_text(search_tags_list.join(" "))
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
          tags << self.send(tag)
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
        
  
  class Config
    
    cattr_accessor  :search_models
    cattr_accessor  :public_models
    
    self.search_models = []
    self.public_models = []
    
    def self.get_search_models
      self.search_models.map {|m| m.constantize}  
    end
    
    def self.get_public_models
      self.public_models.map {|m| m.constantize}  
    end  
    
  end  
  
  
end


ActiveRecord::Base.send(:include, SmartSearch)
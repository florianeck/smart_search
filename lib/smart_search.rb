# -*- encoding : utf-8 -*-
require "rails"

require "smart_search"
require "smart_search/engine"

require "smart_similarity"
require "smart_search_history"
require "smart_search_tag"


module SmartSearch

  def self.included(base)
    base.extend ClassMethods
  end

  # Class Methods for ActiveRecord
  module ClassMethods
    # Enable SmartSearch for the current ActiveRecord model.
    # accepts options:
    # - :on, define which attributes to add to the search index
    # - :conditions, define default scope for all queries made
    # - :group, group by column
    # - :order, order by column
    # see readme for details
    def smart_search(options = {:on => [], :conditions => nil, :group => nil, :order => "created_at", :force => false})
      if table_exists?
        # Check if search_tags exists
        if !is_smart_search? || options[:force] == true || Rails.env == "test"

          cattr_accessor :condition_default, :group_default, :tags, :order_default, :enable_similarity, :default_template_path
          send :include, InstanceMethods
          self.send(:after_save, :create_search_tags, :if => :update_search_tags?) unless options[:auto] == false
          self.send(:before_destroy, :clear_search_tags)
          self.enable_similarity ||= true

          attr_accessor :query_score, :dont_update_search_tags

          # options zuweisen
          if options[:conditions].is_a?(String) && !options[:conditions].blank?
            self.condition_default = options[:conditions]
          elsif !options[:conditions].nil?
            raise ArgumentError, ":conditions must be a valid SQL Query"
          else
            self.condition_default = nil
          end

          self.order_default = options[:order]

          self.tags = options[:on] || []
        elsif is_smart_search?
          # Allow re-adding attributes for search
          logger.info("Re-Adding search data on #{self.name}: #{options[:on].inspect}".yellow)
          self.tags += options[:on]
        end
          
      end
    end

    # Verify if SmartSearch already loaded for this model
    def is_smart_search?
      self.included_modules.include?(InstanceMethods)
    end

    # defines where to look for a partial to load when displaying results for this model
    def result_template_path
      "/search/results/#{self.name.split("::").last.underscore}"
    end

    # Serach database for given search tags
    def find_by_tags(tags = "", options = {})
      if self.is_smart_search?

        tags = tags.join(" ") if tags.is_a?(Array)

        # Save Data for similarity analysis
        if tags.size > 3
          self.connection.execute("INSERT INTO #{::SmartSearchHistory.quoted_table_name} (#{ActiveRecord::Base.connection.quote_column_name('query')}) VALUES ('#{tags.gsub(/[^a-zA-ZäöüÖÄÜß\ ]/, '')}');")
        end

        tags = tags.gsub(/[\(\)\[\]\'\"\*\%\|\&]/, '').split(/[\ -]/).select {|t| !t.blank?}

        # Fallback for Empty String
        tags << "#" if tags.empty?

        # Similarity
        if self.enable_similarity == true
          tags.map! do |t|
            similars = SmartSimilarity.similars(t, :increment_counter => true).join("|")
            case ActiveRecord::Base.connection.adapter_name
            when 'PostgreSQL'
              "search_tags ~* '#{similars}'"
            else
              "search_tags REGEXP '#{similars}'"
            end  
          end

        else
          tags.map! {|t| "search_tags LIKE '%#{t}%'"}
        end

        # Load ranking from Search tags
        result_ids = []
        result_scores = {}
        
        group_method = case ActiveRecord::Base.connection.adapter_name
        when 'PostgreSQL'
          "array_agg"
        else
          "group_concat"
        end
        
        
        SmartSearchTag.connection.select_all("select entry_id, sum(boost) as score, #{group_method}(search_tags) as grouped_tags
        from smart_search_tags where #{ActiveRecord::Base.connection.quote_column_name('table_name')}= '#{self.table_name}' and
        (#{tags.join(' OR ')}) group by entry_id order by score DESC").each do |r|
        result_ids << r["entry_id"].to_i
        result_scores[r["entry_id"].to_i] = r['score'].to_f
      end

      # Enable unscoped searching
      if options[:unscoped] == true
        results     =  self.unscoped.where(self.primary_key => result_ids)
      else
        results     =  self.where(self.primary_key => result_ids)
      end

      if options[:conditions]
        results = results.where(options[:conditions])
      end

      if !self.condition_default.blank?
        results = results.where(self.condition_default)
      end

      if options[:group]
        results = results.group(options[:group])
      end

      if options[:order] || self.order_default
        results = results.order(options[:order] || self.order_default)
      else
        ordered_results = []
        results.each do |r|
          r.query_score = result_scores[r.id]
          ordered_results[result_ids.index(r.id)] = r
        end

        results = ordered_results.compact
      end

      return results
    else
      raise "#{self.inspect} is not a SmartSearch"
    end
  end

  # reload search_tags for entire table based on the attributes defined in ':on' option passed to the 'smart_search' method
  def set_search_index
    s = self.all.size.to_f
    self.all.each_with_index do |a, i|
      a.create_search_tags
      done = ((i+1).to_f/s)*100
    end
  end

  # Load all search tags for this table into similarity index
  def set_similarity_index
    search_tags_list = self.connection.select_all("SELECT search_tags from #{SmartSearchTag.table_name} where `table_name` = #{self.table_name}").map {|r| r["search_tags"]}

    SmartSimilarity.create_from_text(search_tags_list.join(" "))
  end

end

# Instance Methods for ActiveRecord
module InstanceMethods

  # Load the result template path for this instance
  def result_template_path
    self.class.result_template_path
  end

  def dont_update_search_tags!
    self.dont_update_search_tags = true
  end

  def update_search_tags?
    !self.dont_update_search_tags
  end

  # create search tags for this very record based on the attributes defined in ':on' option passed to the 'Class.smart_search' method
  def create_search_tags
    # storing tags must never fail the systems
    begin
      tags      = []
         
      self.class.tags.each do |tag|

        if !tag.is_a?(Hash)
          tag = {:field_name => tag, :boost => 1, :search_tags => ""}
        else
          tag[:search_tags] = ""
          tag[:boost] ||= 1
        end

        if tag[:field_name].is_a?(Symbol)
          tag[:search_tags] << self.send(tag[:field_name]).to_s
        elsif tag[:field_name].is_a?(String)
          tag_methods = tag[:field_name].split(".")
          tagx = self.send(tag_methods[0])
          tag_methods[1..-1].each do |x|
            tagx = tagx.send(x) rescue ""
          end
          tag[:search_tags] << tagx.to_s
        end

        tag[:search_tags] = tag[:search_tags].split(" ").uniq.join(" ").downcase.clear_html
        tags << tag
      end


      self.clear_search_tags

      # Merge search tags with same boost
      @merged_tags = {}

      tags.each do |t|
        boost = t[:boost]

        if @merged_tags[boost]

          @merged_tags[boost][:field_name] << ",#{t[:field_name]}"
          @merged_tags[boost][:search_tags] << " #{t[:search_tags]}"
        else
          @merged_tags[boost] = {:field_name => "#{t[:field_name]}", :search_tags => t[:search_tags], :boost => boost }
        end

      end

      @merged_tags.values.each do |t|
        if !t[:search_tags].blank? && t[:search_tags].size > 1
          begin
            SmartSearchTag.create(t.merge!(:table_name => self.class.table_name, :entry_id => self.id, :search_tags => t[:search_tags].strip.split(" ").uniq.join(" ")))
          rescue Exception => e
            
          end
        end
      end
        
    rescue Exception => e
      Rails.logger.error "SMART SEARCH FAILED TO TO STORE SEARCH TAGS #{self.class.name} #{self.id}"
      Rails.logger.error e.message
      Rails.logger.error puts e.backtrace
    end
      
      

      

  end

  # Remove search data for the instance from the index
  def clear_search_tags
    if !self.id.nil?
      SmartSearchTag.connection.execute("DELETE from #{SmartSearchTag.table_name} where `table_name` = '#{self.class.table_name}' and entry_id = #{self.id}") rescue nil
    end
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
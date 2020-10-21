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
    def smart_search(options = {:on => [], :split => false})
      if table_exists?
        if SmartSearch::Config.search_models.index(self.name).nil?
          SmartSearch::Config.search_models << self.name
        end
        # Check if search_tags exists
        if !is_smart_search?

          cattr_accessor :condition_default, :group_default, :tags, :order_default, :enable_similarity, :default_template_path

          # BETA!
          cattr_accessor :split_searchable_fields
          self.split_searchable_fields = options[:split]

          send :include, InstanceMethods
          self.send(:after_commit, :create_search_tags, :if => :update_search_tags?) unless options[:auto] == false
          self.send(:after_destroy, :clear_search_tags)
          self.enable_similarity ||= true

          attr_accessor :query_score, :dont_update_search_tags

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

    # Serach database for given search tags
    def find_by_tags(tags = "", options = {})

      tags = store_history_and_get_sanitized_search_tags(tags)
      tags = map_similarity_tags(tags)

      result_ids = []

      #results = SmartSearchTag.select("entry_id, sum(boost) as score").group(:entry_id).where(table_name: self.table_name)

      query = case ActiveRecord::Base.connection.adapter_name
          when 'PostgreSQL'
            "select entry_id #{SmartSearch::Config.order_by_score ? ', sum(boost) as score' : ''}
                  from smart_search_tags where #{ActiveRecord::Base.connection.quote_column_name('table_name')}= '#{self.table_name}'
                  GROUP BY entry_id
                  HAVING (#{tags.join(' AND ')})
                  #{SmartSearch::Config.order_by_score ? 'ORDER BY score DESC' : ''}"

          else
            "select entry_id #{SmartSearch::Config.order_by_score ? ', sum(boost) as score' : ''}, #{adapater_based_group_method}(search_tags) as grouped_tags
                  FROM smart_search_tags
                  WHERE #{ActiveRecord::Base.connection.quote_column_name('table_name')}= '#{self.table_name}' and
                  (#{tags.join(' AND ')})
                  GROUP BY entry_id
                  #{SmartSearch::Config.order_by_score ? 'ORDER BY score DESC' : ''}"
          end


      SmartSearchTag.connection.select_all(query).each do |r|
        result_ids << r["entry_id"].to_i
      end

      results     =  self.where(self.primary_key => result_ids)

      results = results.offset(options[:offset]) if options[:offset]
      results = results.limit(options[:limit]) if options[:per_page]
      results = results.reorder(self.order_default) if self.order_default

      return results
    end

    def find_by_splitted_tags(search_fields = {})
      sanitized_search_fields = {}
      search_fields.each do |field, tags|
        next if tags.blank?
        sanitized_search_fields[field] = map_similarity_tags(
          store_history_and_get_sanitized_search_tags(tags)
        )
      end

      result_list = []

      sanitized_search_fields.each do |field_name, query|
        next if query == '#' # skip blank queries
        result_list << SmartSearchTag.where(table_name: self.table_name, field_name: field_name)
          .having(query.join(' AND ')).group(:entry_id).pluck(:entry_id)
      end

      result_ids = eval(result_list.map(&:to_s).join(" & "))
      self.where(self.primary_key => result_ids)
    end

    # Private Query Helper Methods
    private
    def store_history_and_get_sanitized_search_tags(orig_tags)
      orig_tags = orig_tags.join(" ") if orig_tags.is_a?(Array)
      sanitized_tags = orig_tags.gsub(/[\(\)\[\]\'\"\*\%\|\&]/, '').split(/[\ -]/).select {|t| !t.blank?}

      # Save Data for similarity analysis
      if sanitized_tags.join(' ').size > 3
        ::SmartSearchHistory.create(
          query: sanitized_tags.join(' ').gsub(/[^a-zA-ZäöüÖÄÜß\ ]/, '')
        )
      end

      # Fallback for Empty String
      sanitized_tags << "#" if sanitized_tags.empty?

      return sanitized_tags
    end

    def map_similarity_tags(tags)
      # Similarity
      if self.enable_similarity == true
        tags.map do |t|
          similars = SmartSimilarity.similars(t, :increment_counter => true).join("|")
          case ActiveRecord::Base.connection.adapter_name
          when 'PostgreSQL'
            "string_agg(search_tags, ' ') ~* '#{similars}'"
          else
            "search_tags REGEXP '#{similars}'"
          end
        end

      else
        tags.map {|t| "search_tags LIKE '%#{t}%'"}
      end
    end

    def adapater_based_group_method
      case ActiveRecord::Base.connection.adapter_name
      when 'PostgreSQL'
        "array_agg"
      else
        "group_concat"
      end
    end

    # Public Mainenance Helper Methods
    public

    # reload search_tags for entire table based on the attributes defined in ':on' option passed to the 'smart_search' method
    def set_search_index
      threads = [(%x(nproc).strip.to_i)-2, 2].max

      Parallel.each(self.all, in_processes: threads, progress: "Setting index for: #{self.name}" , progress_options: { format: "%t: (%c/%C) |%W| %f" }) do |a|
        a.create_search_tags
      end
    end

    # Load all search tags for this table into similarity index
    def set_similarity_index
      SmartSimilarity.create_from_text(
        SmartSearchTag.where(table_name: self.table_name).pluck(:search_tags).join(' ')
      )
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

        self.get_calculated_tags_list!
        self.clear_search_tags

        (self.class.split_searchable_fields ? @calculated_tags_list : get_merged_calculated_tags).each do |t|
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

    def get_calculated_tags_list!
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

      return @calculated_tags_list = tags
    end

    def get_merged_calculated_tags
      # Merge search tags with same boost
      merged_tags = {}

      @calculated_tags_list.each do |t|
        boost = t[:boost]

        if merged_tags[boost]
          merged_tags[boost][:field_name] << ",#{t[:field_name]}"
          merged_tags[boost][:search_tags] << " #{t[:search_tags]}"
        else
          merged_tags[boost] = {:field_name => "#{t[:field_name]}", :search_tags => t[:search_tags], :boost => boost }
        end
      end

      return merged_tags.values
    end

    # Remove search data for the instance from the index
    def clear_search_tags
      SmartSearchTag.connection.execute("DELETE from #{SmartSearchTag.table_name} where table_name = '#{self.class.table_name}' and entry_id = #{self.id}") rescue nil
    end
  end

  class Config

    cattr_accessor  :search_models
    cattr_accessor  :public_models
    cattr_accessor  :order_by_score

    self.search_models = []
    self.public_models = []
    self.order_by_score = true

    def self.get_search_models
      self.search_models.map {|m| m.constantize}
    end

    def self.get_public_models
      self.public_models.map {|m| m.constantize}
    end

    def self.rebuild_index
      puts "Rebuilding Search index..."

      SmartSearch::Config.search_models.each do |name|
        puts "... #{name}"
      end

      ActiveRecord::Base.logger = nil

      model_bar = ProgressBar.create(:title => "Building models", :total => SmartSearch::Config.search_models.size, format: "%t: (%c/%C) |%W| %f")

      SmartSearch::Config.get_search_models.each do |model|
        puts model.tags.join("\n")
        entry_bar = ProgressBar.create(:title => model.name, :total => model.all.size, format: "%t: (%c/%C) |%W| %f")
        model.all.each do |entry|
          entry.create_search_tags
          entry_bar.increment
        end

        model_bar.increment
        puts "\n\n"
      end
    end
  end


end

ActiveRecord::Base.send(:include, SmartSearch)
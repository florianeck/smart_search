# Represents the search index
class SmartSearchTag < ActiveRecord::Base
  
  
  # Get a list of available search tags
  def self.tags_list(query, table= nil)
    if query.size < 3
      return []
    else  
      list = sql_query!("select search_tags from #{self.table_name} where search_tags like '%#{query}%' #{"and table_name = '#{table}'" if table} ").map {|r| r['search_tags']}
      list = list.join(" ").clear_html.split(" ").uniq
      return list.sort.grep(Regexp.new(query))
    end  
  end  
  
end  
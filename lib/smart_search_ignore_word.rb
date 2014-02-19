# The keep words out of the index, they can be added into this table
# TODO: Its not working yet
class SmartSearchIgnoreWord < ActiveRecord::Base

  #= Configuration
  self.table_name = "smart_search_ignore_words" 
      #== Associations
          # => Stuff in Here
  
      #== Plugins and modules
        #=== PlugIns
          # => Stuff in Here        
  
        #=== include Modules
          # => Stuff in Here
  
      #== Konstanten
          # => Stuff in Here
  
      #== Validation and Callbacks
        #=== Validation
          validates_uniqueness_of :word
          
        #=== Callbacks
          # => Stuff in Here
          
          
    # => END
  
end  
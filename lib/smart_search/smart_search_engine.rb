# :nodoc:
module SmartSearch
  require "rails"
  # :nodoc:
  class SmartSearchEngine < Rails::Engine
    isolate_namespace SmartSearch
    require "friendly_extensions"
    require "amatch"
  end  
end  
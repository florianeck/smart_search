module SmartSearch
  class Engine < Rails::Engine

    engine_name 'smart_search'
    
    isolate_namespace SmartSearch
    require "friendly_extensions"
    require "amatch"

  end
end


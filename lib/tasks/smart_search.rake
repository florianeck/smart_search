namespace :smart_search do
  desc "Load similarity data from query history"
  task :similarity_from_query_history => :environment do
    require File.expand_path("../../smart_similarity", __FILE__)
    SmartSimilarity.load_from_query_history
  end
end



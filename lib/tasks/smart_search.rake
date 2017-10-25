namespace :smart_search do
  desc "Load similarity data from query history"
  task :similarity_from_query_history => :environment do
    require File.expand_path("../../smart_similarity", __FILE__)
    SmartSimilarity.load_from_query_history
  end

  desc "Load similarity data from url - Use URL=http://.../ to specify url - Requires 'curl'"
  task :similarity_from_url => :environment do
    require File.expand_path("../../smart_similarity", __FILE__)
    if ENV['URL'].nil?
      raise ArgumentError, "No URL specified. "
    else
      SmartSimilarity.load_url(ENV['URL'])
    end
  end

end



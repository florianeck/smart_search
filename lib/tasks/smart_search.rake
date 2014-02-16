namespace :smart_search do
  desc "Load similarity data from query history"
  task :similarity_from_query_history => :environment do
    require File.expand_path("../../smart_similarity", __FILE__)
    SmartSimilarity.load_from_query_history
  end
  
  desc "Load similarity data from file - Use FILE=path/to/file to specify file"
  task :similarity_from_file => :environment do
    require File.expand_path("../../smart_similarity", __FILE__)
    if ENV['FILE_PATH'].nil?
      raise ArgumentError, "No file specified. "
    elsif !File.exist?(ENV['FILE_PATH'])
      raise ArgumentError, "File not found "
    else    
      SmartSimilarity.load_file(ENV['FILE_PATH'])
    end  
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
  
  
  
  desc "load ignore words list"
  task :load_ignore_words => :environment do
    require File.expand_path("../../smart_search_ignore_word", __FILE__)
    
    dic_path = File.expand_path("../../../dictionaries/*", __FILE__)
    
    raise dic_path.inspect
    
    dic_folders = Dir.glob(dic_path).select {|d| File.directory?(d)}
    
    dic_folders.each do |folder|
      locale = folder.split("/").last
      word_file = File.join(folder, "#{locale}.ignore_words.dic")
      if File.exists?(word_file)
        File.open(word_file, "r").each_line do |word|
          SmartSearchIgnoreWord.create(:word => word.strip.downcase, :locale => locale)
        end  
      end  
    end  
  end   
  
  

    
end  



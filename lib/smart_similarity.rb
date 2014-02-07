class SmartSimilarity < ActiveRecord::Base
  #= Configuration
  serialize :similarities, Array
  self.table_name = "smart_search_similarities"
  require "amatch"
  
      #== Associations
          # => Stuff in Here

      #== Plugins and modules
        #=== PlugIns
          # => Stuff in Here        

        #=== include Modules
          # => Stuff in Here

      #== Konstanten
          SIMILARITY_FACTOR = 0.8
          SIMILARITY_METHOD_1 = :jarowinkler
          SIMILARITY_METHOD_2 = :levenshtein
          
          # Limit Number of similar words
          SIMILARITY_LIMIT  = 8
      #== Validation and Callbacks
        #=== Validation
        
        #=== Callbacks
          # => Stuff in Here
    # => END
  
    def self.create_from_text(text)
      # prepare text
      prepared_text = text.downcase.split(/\b/).uniq
      prepared_text = prepared_text.select {|w| w.size >= 3 && !w.match(/[0-9\-_<>\.\/(){}&\?"'@*+$!=,:'“„#;]/)}
      list = {}
      prepared_text.each do |word|
        # Load index from database
        words_in_db = self.find_by_phrase(word)
        if words_in_db.nil?
          self.connection.execute "INSERT INTO `#{self.table_name}` (`phrase`, `ind`) VALUES ('#{word}', '#{word[0..1]}');
"
          current = []
        else  
          current = words_in_db.similarities
        end  
        
        current += prepared_text.select {|w| w != word && self.match_words(w,word) >= SIMILARITY_FACTOR}
        
        list[word] = current.uniq
      end  
      
      # Write to Database
      list.each do |word, sims|
        sims = sims.sort_by {|s| self.match_words(s,word) }.reverse.first(SIMILARITY_LIMIT)
        
        self.connection.execute 'UPDATE %s set similarities = "%s" where phrase = "%s"' % [self.table_name, sims.to_yaml, word] rescue nil
      end  
    end
    
    def self.add_word(word)
      words = [word]
      phrases = self.connection.select_all("SELECT phrase from smart_search_similarities").map {|r| r["phrase"] }  
      words +=  phrases.select {|p| self.match_words(p,word) >= SIMILARITY_FACTOR }
      
      self.create_from_text(words.join(" "))
    end
    
    def self.load_file(path)
      count = %x{wc -l #{path}}.split[0].to_i
      File.open(path, "r").to_a.seperate(12).each_with_index do |stack, si| 
        Spawnling.new(:argv => "sim-file-#{si}") do
          QueryLog.info "sim-file-#{si}"
          stack.each_with_index do |l,i|
            QueryLog.info "#{si}: #{i.fdiv(count).round(4)} %"
            self.add_word(l)
          end
        end  
      end  
    end
    
    def self.load_url(url)
      self.create_from_text(%x(curl #{url}))
    end  
    
    def self.load_from_query_history
      queries = self.connection.select_all("SELECT query from `#{::SmartSearchHistory.table_name}`").map {|r| r["query"]}.join(" ")
      self.create_from_text(queries)
      self.connection.execute("TRUNCATE `#{::SmartSearchHistory.table_name}`")
    end
    
    # Get array of similar words including orig word
    def self.similars(word)      
      list = self.where(:phrase => word)
      if list.empty?
        return [word]
      else
        return [word, list.first.similarities].flatten
      end    
    end
    
    def match_words(word1, word2)
      x1 = word1.send("#{SIMILARITY_METHOD_1}_similar", word2)
      x2 = word1.send("#{SIMILARITY_METHOD_2}_similar", word2)
      return (x1+x2)/2.0
    end    
  
end 

var search_data = {"index":{"searchIndex":["smartsearch","classmethods","config","instancemethods","smartsearchengine","smartsearchhistory","smartsearchignoreword","smartsearchtag","smartsimilarity","add_word()","clear_search_tags()","create_from_text()","create_search_tags()","find_by_tags()","get_public_models()","get_search_models()","included()","is_smart_search?()","load_file()","load_from_query_history()","load_url()","match_words()","result_template_path()","result_template_path()","set_search_index()","set_similarity_index()","similars()","smart_search()"],"longSearchIndex":["smartsearch","smartsearch::classmethods","smartsearch::config","smartsearch::instancemethods","smartsearch::smartsearchengine","smartsearchhistory","smartsearchignoreword","smartsearchtag","smartsimilarity","smartsimilarity::add_word()","smartsearch::instancemethods#clear_search_tags()","smartsimilarity::create_from_text()","smartsearch::instancemethods#create_search_tags()","smartsearch::classmethods#find_by_tags()","smartsearch::config::get_public_models()","smartsearch::config::get_search_models()","smartsearch::included()","smartsearch::classmethods#is_smart_search?()","smartsimilarity::load_file()","smartsimilarity::load_from_query_history()","smartsimilarity::load_url()","smartsimilarity::match_words()","smartsearch::classmethods#result_template_path()","smartsearch::instancemethods#result_template_path()","smartsearch::classmethods#set_search_index()","smartsearch::classmethods#set_similarity_index()","smartsimilarity::similars()","smartsearch::classmethods#smart_search()"],"info":[["SmartSearch","","SmartSearch.html","",""],["SmartSearch::ClassMethods","","SmartSearch/ClassMethods.html","","<p>Class Methods for ActiveRecord\n"],["SmartSearch::Config","","SmartSearch/Config.html","",""],["SmartSearch::InstanceMethods","","SmartSearch/InstanceMethods.html","","<p>Instance Methods for ActiveRecord\n"],["SmartSearch::SmartSearchEngine","","SmartSearch/SmartSearchEngine.html","",""],["SmartSearchHistory","","SmartSearchHistory.html","","<p>Saves all queries made so the data can be used to build a similarity index\nbased on the queries made …\n"],["SmartSearchIgnoreWord","","SmartSearchIgnoreWord.html","","<p>The keep words out of the index, they can be added into this table TODO:\nIts not working yet\n"],["SmartSearchTag","","SmartSearchTag.html","","<p>Represents the search index\n"],["SmartSimilarity","","SmartSimilarity.html","","<p>This class is used to build similiarity index\n"],["add_word","SmartSimilarity","SmartSimilarity.html#method-c-add_word","(word)","<p>Add one simgle word to database and check if there are already similars\n"],["clear_search_tags","SmartSearch::InstanceMethods","SmartSearch/InstanceMethods.html#method-i-clear_search_tags","()","<p>Remove search data for the instance from the index\n"],["create_from_text","SmartSimilarity","SmartSimilarity.html#method-c-create_from_text","(text)","<p>Create similarity data based on the given text This method is used to\ngenerate date from every source, …\n"],["create_search_tags","SmartSearch::InstanceMethods","SmartSearch/InstanceMethods.html#method-i-create_search_tags","()","<p>create search tags for this very record based on the attributes defined in\n&#39;:on&#39; option passed …\n"],["find_by_tags","SmartSearch::ClassMethods","SmartSearch/ClassMethods.html#method-i-find_by_tags","(tags = \"\", options = {})","<p>Serach database for given search tags\n"],["get_public_models","SmartSearch::Config","SmartSearch/Config.html#method-c-get_public_models","()",""],["get_search_models","SmartSearch::Config","SmartSearch/Config.html#method-c-get_search_models","()",""],["included","SmartSearch","SmartSearch.html#method-c-included","(base)",""],["is_smart_search?","SmartSearch::ClassMethods","SmartSearch/ClassMethods.html#method-i-is_smart_search-3F","()","<p>Verify if SmartSearch already loaded for this model\n"],["load_file","SmartSimilarity","SmartSimilarity.html#method-c-load_file","(path)","<p>Load an entire file to the index. Best used for loading big dictionary\nfiles. Uses &#39;spawnling&#39; …\n"],["load_from_query_history","SmartSimilarity","SmartSimilarity.html#method-c-load_from_query_history","()","<p>Loads your created query history and saves them to the index\n"],["load_url","SmartSimilarity","SmartSimilarity.html#method-c-load_url","(url)","<p>Load words from website and save them to index\n"],["match_words","SmartSimilarity","SmartSimilarity.html#method-c-match_words","(word1, word2)","<p>Return match score for two words bases und the two defined similarity\nmethods\n"],["result_template_path","SmartSearch::ClassMethods","SmartSearch/ClassMethods.html#method-i-result_template_path","()","<p>defines where to look for a partial to load when displaying results for\nthis model\n"],["result_template_path","SmartSearch::InstanceMethods","SmartSearch/InstanceMethods.html#method-i-result_template_path","()","<p>Load the result template path for this instance\n"],["set_search_index","SmartSearch::ClassMethods","SmartSearch/ClassMethods.html#method-i-set_search_index","()","<p>reload search_tags for entire table based on the attributes defined in\n&#39;:on&#39; option passed to …\n"],["set_similarity_index","SmartSearch::ClassMethods","SmartSearch/ClassMethods.html#method-i-set_similarity_index","()","<p>Load all search tags for this table into similarity index\n"],["similars","SmartSimilarity","SmartSimilarity.html#method-c-similars","(word, options = {})","<p>Get array of similar words including orig word\n"],["smart_search","SmartSearch::ClassMethods","SmartSearch/ClassMethods.html#method-i-smart_search","(options = {:on => [], :conditions => nil, :group => nil, :order => \"created_at\", :force => false})","<p>Enable SmartSearch for the current ActiveRecord model. accepts options:\n<p>:on, define which attributes to …\n"]]}}
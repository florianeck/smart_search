Gem::Specification.new do |s|
  s.name        = 'smart_search'
  s.version     = '0.0.68'
  s.summary     = "Simple, easy to use search MySQL based search for ActiveRecord"
  s.description = "SmartSearch adds full-text search functions to ActiveRecord running with MySQL, including search for similiar words. Its fast, simple, and works with almost zero-config!"
  s.authors     = ["Florian Eck"]
  s.email       = 'it-support@friends-systems.de'
  s.files       = [Dir.glob("lib/**/*"), Dir.glob("app/**/*"), Dir.glob("config/**/*")].flatten
  s.test_files  =   Dir.glob("test/**/*")
  s.homepage    = 'https://github.com/florianeck/smart_search'
  
  s.add_dependency "rails", ">= 3.2.9"
  s.add_dependency "amatch"
  s.add_dependency "friendly_extensions", "~> 0.0.61"
  s.add_dependency "mysql2" 
end
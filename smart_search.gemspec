Gem::Specification.new do |s|
  s.name        = 'smart_search'
  s.version     = '0.0.6'
  s.date        = '2013-03-11'
  s.summary     = "Simple, easy to use search."
  s.description = "Adds easy to use full-text search to ActiveRecord models, based the attributes you want to search."
  s.authors     = ["Florian Eck"]
  s.email       = 'it-support@friends-systems.de'
  s.files       = [Dir.glob("lib/**/*"), Dir.glob("app/**/*"), Dir.glob("config/**/*")].flatten
  s.test_files  =   Dir.glob("test/**/*")
  s.homepage    = 'https://rubygems.org/gems/smart_search'
  
  s.add_dependency "amatch"
end
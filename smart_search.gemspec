Gem::Specification.new do |s|
  s.name        = 'smart_search'
  s.version     = '1.0.2'
  s.summary     = "Simple, easy to use search MySQL based search for ActiveRecord"
  s.description = "SmartSearch adds full-text search functions to ActiveRecord running with MySQL, including search for similiar words. Its fast, simple, and works with almost zero-config!"
  s.authors     = ["Florian Eck"]
  s.email       = 'florian.eck@el-digital.de'
  s.files       = [Dir.glob("lib/**/*"), Dir.glob("app/**/*"), Dir.glob("config/**/*")].flatten
  s.test_files  =   Dir.glob("test/**/*")
  s.homepage    = 'https://github.com/florianeck/smart_search'

  s.add_dependency "rails", ">= 4.0.4"
  s.add_dependency "amatch"
  s.add_dependency "friendly_extensions"
  s.add_dependency "unicode-emoji"
  s.add_dependency "ruby-progressbar"
  s.add_dependency  "parallel"
end
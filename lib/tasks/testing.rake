require "active_record"
namespace :db do
  desc "Create test database. Overwrite dasebase config with USERNAME=, PASSWORD=, DATABASE="
  task :create_test_db do
    config = YAML::load(File.open(File.expand_path("config/database.yml")))["test"]
    
    # Overwrite config
    config.merge!('database' => ENV['DATABASE']) if ENV['DATABASE']
    config.merge!('username' => ENV['USERNAME']) if ENV['USERNAME']
    config.merge!('password' => ENV['PASSWORD']) if ENV['PASSWORD']
    
    ActiveRecord::Base.establish_connection(config.merge('database' => nil))
    ActiveRecord::Base.connection.drop_database(config['database']) rescue nil
    ActiveRecord::Base.connection.create_database(config['database'])
    ActiveRecord::Base.establish_connection(config)
  end
  
  task :migrate do
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
  end    
end  

task :test_smart_search do
  Rake::Task["db:create_test_db"].execute
  Rake::Task["db:migrate"].execute
  Rake::Task["test"].execute
end  

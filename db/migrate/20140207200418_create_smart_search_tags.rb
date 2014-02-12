class CreateSmartSearchTags < ActiveRecord::Migration
  def up
    create_table :smart_search_tags, :force => true, :id => false do |t|
      t.string    :table_name
      t.integer   :entry_id
      t.text      :search_tags
      t.string    :field_name
      t.decimal   :boost, :scale => 2, :precision => 10, :default => 1
    end
    
    add_index :smart_search_tags, :table_name
    
    create_table :smart_search_ignore_words, :force => true, :id => false do |t|
      t.string  :word
      t.string  :locale
      t.string  :group
    end  
    
    add_index :smart_search_ignore_words, :locale
    
  end

  def down
  end
end
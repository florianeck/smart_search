class CreateSmartSearchTags < ActiveRecord::Migration[4.2]
  def change
    create_table :smart_search_tags, :force => true, :id => false do |t|
      t.string    :table_name
      t.integer   :entry_id
      t.text      :search_tags
      t.text      :field_name
      t.decimal   :boost, :scale => 2, :precision => 10, :default => 1
    end
    
    add_index :smart_search_tags, :table_name
    add_index :smart_search_tags, :entry_id
    
    create_table :smart_search_similarities, :force => true, :id => false do |t|
      t.string  :phrase
      t.text    :similarities
      t.integer :count, :default => 0
      t.string  :ind
    end
    
    add_index :smart_search_similarities, :ind
    
    create_table :smart_search_histories, :force => true, :id => false do |t|
      t.string :query
    end
  end

end
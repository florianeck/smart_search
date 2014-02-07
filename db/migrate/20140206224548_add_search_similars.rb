class AddSearchSimilars < ActiveRecord::Migration
  def up
    create_table :smart_search_similarities, :force => true, :id => false do |t|
      t.string  :phrase
      t.text    :similarities
      t.integer :count, :default => 0
      t.string  :ind
    end
    
    add_index :smart_search_similarities, :ind
  end

  def down
  end
end
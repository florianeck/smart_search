class AddSmartSearchSimilarsAndHistory < ActiveRecord::Migration
  def up
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

  def down
  end
end
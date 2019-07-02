class DropDeprecatedIgnoreTable < ActiveRecord::Migration[4.2]
  def change
    if table_exists?(:smart_search_ignore_words)
      drop_table :smart_search_ignore_words
    end
  end

end
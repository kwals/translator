class AddTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password
    end
    create_table :items do |t|
      t.text :original_text
      t.text :translated_text
      t.text :user_content
      t.string :original_language
      t.string :translated_language
      t.string :genre
      t.integer :user_id
      t.timestamps
    end
    create_table :comments do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :points
      t.text :content 
    end
  end
end

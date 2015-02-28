class ChangeTitleColumn < ActiveRecord::Migration
  def change
    change_column :items, :title, :string, null: false
  end
end

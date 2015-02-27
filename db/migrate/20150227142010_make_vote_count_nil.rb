class MakeVoteCountNil < ActiveRecord::Migration
  def change
      change_column_default(:comments, :points ,0)
  end
end

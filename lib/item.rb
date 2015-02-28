class Item <ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def self.rank_by_comments 
    sorter = []
    sorter = Item.all.map {|i| [i.id, i.comments.count]}
  end
end
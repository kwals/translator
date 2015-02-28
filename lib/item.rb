class Item <ActiveRecord::Base
  belongs_to :user
  has_many :comments
  validates :title, presence: true

  def self.sort_by_comments 
    sorter = {}
    Item.all.each {|i| sorter[i.comments.count] = i.id}
    sorter.sort_by{|count, id| count}.reverse
  end
end
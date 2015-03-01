class Comment <ActiveRecord::Base
  belongs_to :user
  belongs_to :item

  def upvote!
    self.points += 1
    self.save!
  end

  def downvote!
    self.points -= 1
    self.save!
  end

end
class Comment <ActiveRecord::Base
  belongs_to :user
  belongs_to :item

  def upvote
  end

  def downvote
  end

end
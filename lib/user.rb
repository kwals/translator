class User <ActiveRecord::Base
  has_many :items
  has_many :comments

  validates :email, presence: true
  validates :email, uniqueness: true

  def create_item! original_text: nil, translated_text: nil, user_content: nil, original_language: nil, translated_language: nil, genre: nil
    self.items.create!(
      title: title,
      original_text: original_text,
      translated_text: translated_text,
      user_content: user_content,
      original_language: original_language,
      translated_language: translated_language,
      genre: genre
      )
  end

  def comment item, content
    self.comments.create!(item_id: item.id, content: content)
  end
end
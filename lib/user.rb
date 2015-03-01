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

  def self.create_user name, email, password
    User.create!(name: name, email: email.downcase, password: Digest::SHA1.hexdigest(password))
  end

  def welcome_email
    {
        :subject => "Welcome to Translator",
        :from_name => "Translator Team",
        :text => "Hi! Welcome to Translator. Come visit our site: ___. Your username is #{name}. Your current password is #{password}. Log in and change it because SECURITY. :)",
        :to => [{:email=> "#{email}", :name => "#{name}"}],
        :from_email=>"DCIronYard@gmail.com"
        }
  end
end
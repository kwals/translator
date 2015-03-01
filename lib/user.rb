class User <ActiveRecord::Base
  has_many :items
  has_many :comments
  validates :email, presence: true
  validates :email, uniqueness: true

  def create_item! title: nil, original_text: nil, translated_text: nil, user_content: nil, original_language: nil, translated_language: nil, genre: nil
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

  def comment id, content
    self.comments.create!(item_id: id, content: content)
  end

  def self.create_user name, email, password
    User.create!(name: name, email: email.downcase, password: Digest::SHA1.hexdigest(password))
  end

  def welcome_email(temp_pass)
    {
        :subject => "Welcome to Translator",
        :from_name => "Translator Team",
        :text => "Hi! Welcome to Translator. Come visit our site: ___. \n\nYour username is: #{name}. \n\nYour current password is: #{temp_pass} \n\nLog in using the email where you received this message and change it because SECURITY. :)",
        :to => [{:email=> "#{email}", :name => "#{name}"}],
        :from_email=>"DCIronYard@gmail.com"
        }
  end
end
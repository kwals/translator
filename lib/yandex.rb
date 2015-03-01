require 'dotenv'
require 'httparty'

class Yandex
  def self.header
    header = {'key' => ENV['YANDEX_KEY']}
  end

  # def self.get_languages 
  #   list = HTTParty.get("https://translate.yandex.net/api/1.5/tr.json/getLangs")
  # end

  def self.translate text
    new_text = HTTParty.post('https://translate.yandex.net/api/v1.5/tr.json/translate',
      body:{'key' => ENV['YANDEX_KEY'],
      'text' => text,
      'lang' => "en"}
      )
    new_text.to_json
  end
end
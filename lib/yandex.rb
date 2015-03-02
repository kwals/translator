require 'dotenv'
require 'httparty'

class Yandex
  def self.header
    header = {'key' => ENV['YANDEX_KEY']}
  end

  def self.translate text, lang="en"
    response = HTTParty.post('https://translate.yandex.net/api/v1.5/tr.json/translate',
      body:{'key' => ENV['YANDEX_KEY'],
      'text' => text,
      'lang' => lang}
      )
    if response["code"] > 200
      return false
    else
      "#{response['lang']} \n \t #{response["text"]}"
    end
  end
end
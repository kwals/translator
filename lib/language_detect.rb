require 'dotenv'
require 'httparty'

class LanguageDetect

def self.detect! text
 response = HTTParty.post("https://community-language-detection.p.mashape.com/detect",
  headers:{
    "X-Mashape-Key" => ENV["MASHAPE-KEY"],
    "Content-Type" => "application/x-www-form-urlencoded",
    "Accept" => "application/json"
  },
  parameters:{
    "q" => text
  })

end
end
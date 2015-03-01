# require 'dotenv'
# require 'httparty'

# class TextCheck

#   def self.check! language='en', text
#   edits = HTTParty.post "https://dnaber-languagetool.p.mashape.com/",
#   headers:{
#     "X-Mashape-Key" => ENV['MASHAPE-KEY'],
#     "Content-Type" => "application/x-www-form-urlencoded",
#     "Accept" => "text/plain"
#   },
#   parameters:{
#     "language" => language,
#     "text" => text
#   }
#   error = edits[error]
# end

# end
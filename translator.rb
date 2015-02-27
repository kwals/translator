require 'sinatra/base'
require 'pry'

#require 'rollbar'
#require 'mandrill'
#require 'digest'

require './db/setup'
require './lib/all'

class Translator < Sinatra::Base

  enable :sessions, :method_override

  def current_user
    fail
  end

  get '/' do
    erb :home
  end  

  get '/shelves'  
    erb :shelf
  end

  post '/shelves'
    @results = if params["original_language"]
      Item.where(original_language: params["original_language"])
    elsif params["translated_language"]
      Item.where(translated_language: params["translated_language"])
    elsif params["genre"]
      Item.where(genre: params["genre"])
    else
      session[:error_message = "Could not find any items from that request. Please try again."]
    end 
    erb :shelf
  end

  #ITEM ROUTES
  get '/Item'
    erb :create_item
  end

  post '/Item'
    x = current_user.create_item!(original_text: params["original_text"], translated_text: params["translated_text"], user_content: params["user_content"], original_language: params["original_language"], translated_language: params["translated_language"], genre: params["genre"])
    redirect "/Item/#{x.id}"
  end

  get '/Item/:id'
    erb :view_item
  end

  post '/Item/:id'
    current_user.comment(params["item_id"], params["content"])
  end

  #USER ROUTES
  get '/User/:id'
    erb :user_profile
  end

  get '/User/:id/edit'
    erb :edit_profile
  end

  patch '/User/:id'
    fail
    #User.find(:id).update!(#params)
  end

  #COMMENT ROUTES
  patch '/comment'
    if params["action"] = "upvote"
      params["comment_id"].upvote!
    elsif params["action"] = "downvote"
      params["comment_id"].downvote!
    end
  end

end

Translator.run! if $PROGRAM_NAME == __FILE__

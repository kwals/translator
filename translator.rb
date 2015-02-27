require 'sinatra/base'
require 'pry'

#require 'rollbar'
#require 'mandrill'
#require 'digest'

require './db/setup'
require './lib/all'

class Spotibetical < Sinatra::Base

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
    x = current_user.create_item!(language_from: params["language_from"], language_to: params["language_to"], original_text: params["original_text"], translated_text: params["translated_text"], genre: params["genre"], user_content: params["user_content"])
    redirect "/Item/#{x.id}"
  end

  get '/Item/:id'
    erb :view_item
  end

  post '/Item/:id' #update
    User.(find)session[user_id:].comment!(params[:id])
  end

  #USER ROUTES
  get '/User/:id'
    erb :user_profile
  end

  get '/User/:id/edit'
    erb :edit_profile
  end

  patch '/User/:id'
    User.find(:id).update!(#params)
  end

end
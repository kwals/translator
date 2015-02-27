require 'sinatra/base'
require 'pry'

#require 'rollbar'
#require 'mandrill'
#require 'digest'

require './db/setup'
require './lib/all'

class Spotibetical < Sinatra::Base

  enable :sessions, :method_override

  get '/' do
    erb :home
  end  

  get '/shelves'
    Item.where(#params)
    erb :shelf
  end


  #ITEM ROUTES
  get '/Item'
    erb :create_item
  end

  post '/Item'
    x = Item.create!(#language_to, #language_from, #user_id, #original_text, #translated_text)
    redirect "/Item/#{x}"
  end

  get '/Item/:id'
    erb :item
  end

  post '/Item/:id'
    Comment.create!(#... item_id: params[:id])
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
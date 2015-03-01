require 'sinatra/base'
require 'pry'

#require 'rollbar'
# require 'mandrill'
require 'digest'

require './db/setup'
require './lib/all'

class Translator < Sinatra::Base

  enable :sessions, :method_override

LOGIN_REQUIRED_ROUTES = [
  "/user/*",
  # "/user/#{current_user.id}",
  # "/user/#{current_user.id}/*",
  "/item/:id/*"
]

  def current_user
    if session[:user_id]
      User.find(session[:user_id])
    end
  end

  LOGIN_REQUIRED_ROUTES.each do |path|
    before path do
      if current_user.nil?
        session[:error_message] = "You must log in to see this feature"
        session[:return_trip] = path
        redirect to('/')
        return
      end
    end 
  end

  post '/login' do
    user = User.where(
      email: params["email"], 
      password: Digest::SHA1.hexdigest(params["password"])
    ).first

    if user
      session[:user_id] = user.id
      if session["return_trip"]
        path = session["return_trip"]
        session.delete("return_trip")
        redirect to(path)
      else
        redirect to('/')
      end
    else
      @error = true 
      status 422
      erb :home
    end
  end

  delete '/logout' do
    session.delete(:user_id)
    redirect to('/')
  end

  get '/' do
    erb :home
  end  

  get '/shelves' do 
    erb :shelf
  end

  post '/shelves' do
    @results = if params["original_language"]
      Item.where(original_language: params["original_language"]).id
    elsif params["translated_language"]
      Item.where(translated_language: params["translated_language"]).id
    elsif params["genre"]
      Item.where(genre: params["genre"]).id
    else
      session[:error_message] = "Could not find any items from that request. Please try again."
    end 
    erb :shelf
  end

  #ITEM ROUTES
  get '/item' do
    erb :create_item
  end

  post '/item' do
    x = current_user.create_item!(title: params["title"], original_text: params["original_text"], translated_text: params["translated_text"], user_content: params["user_content"], original_language: params["original_language"], translated_language: params["translated_language"], genre: params["genre"])
    redirect "/item/#{x.id}"
  end

  get '/item/:id' do
    @id = params["id"]
    erb :view_item
  end

  #USER ROUTES
  get '/user/:id' do
    erb :user_profile
  end

  get '/user/:id/edit' do
    @user = User.find(params["id"])
    erb :edit_profile
  end

  patch '/user/:id' do
    @user = User.find(params["id"])
    fail
    #User.find(:id).update!(#params)
  end

  #COMMENT ROUTES
  patch '/comment' do
    if params["action"] = "upvote"
      params["comment_id"].upvote!
    elsif params["action"] = "downvote"
      params["comment_id"].downvote!
    end
  end

  post '/comment' do
    current_user.comment(params["item_id"], params["comment"])
    redirect back
  end

  post '/translate' do
    @original_text = params["text"]
    @translation = Yandex.translate(params["text"].chomp)
    erb :create_item
  end
end

Translator.run! if $PROGRAM_NAME == __FILE__

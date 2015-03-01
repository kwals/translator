require 'sinatra/base'
require 'pry'

#require 'rollbar'
# require 'mandrill'
require 'digest'

require './db/setup'
require './lib/all'

class Translator < Sinatra::Base

  enable :sessions, :method_override

  ADMIN_REQUIRED_ROUTES = [
    "/admin",
    "/admin/*",
    "/create_account"
  ]

  LOGIN_REQUIRED_ROUTES = [
    "/user/*",
    "/item/:id/*"
  ] + ADMIN_REQUIRED_ROUTES

  def current_user
    if session[:user_id]
      User.find(session[:user_id])
    end
  end

  LOGIN_REQUIRED_ROUTES.each do |path|
    before path do
      if current_user.nil?
        session[:error_message] = "You must log in to see this feature."
        session[:return_trip] = path
        redirect to('/')
        return
      end
      if ADMIN_REQUIRED_ROUTES.include?(path)
        unless current_user.admin
          session[:error_message] = "You don't have permission to access this."
          session[:return_trip] = path 
          redirect to('/')
        end
      end
    end 
  end

  post '/login' do
    user = User.where(
      email: params["email"].downcase, 
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

  #ADMIN ROUTES
  get '/admin' do
    @users = User.all
    erb :admin
  end

  patch '/admin/manage' do
    if params["action"] == "enable"
      User.find(params["id"]).update!(admin: true)
      session[:success_message] = "Success! User #{User.find(params["id"]).name}, ID #{params["id"]}, admin privileges GRANTED."
      redirect '/admin'
    elsif params["action"] == "disable"
      x = User.find(params["id"]).update!(admin: false)
      session[:success_message] = "Success! User #{User.find(params["id"]).name}, ID #{params["id"]}, admin privileges REVOKED."
      redirect '/admin'
    else
      session[:error_message] = "There was an error updating admin privileges for User ID #{params["id"]}. Please try again."
      redirect '/admin'
    end
  end

  post '/create_account' do
    begin 
      x = User.create_user(params["name"], params["email"], params["password"])
      session[:success_message] = "User account for #{x.name} created succesfully. Account ID is #{x.id}."
    rescue 
      session[:error_message] = "User creation failed. Please try again."
    ensure 
      redirect '/admin'
    end
  end

  #COMMENT ROUTES
  patch '/comment' do
    if params["action"] = "upvote"
      params["comment_id"].upvote!
    elsif params["action"] = "downvote"
      params["comment_id"].downvote!
    end
  end

  post '/item/:id/comment' do
    current_user.comment(params["item_id"], params["content"])
  end

end

Translator.run! if $PROGRAM_NAME == __FILE__

require 'sinatra/base'
require 'pry'

#require 'rollbar'
require 'mandrill'
require 'digest'
require 'dotenv'

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

  def make_password
    ('a'..'z').to_a.shuffle[0,8 + rand(4)].join
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
      session[:success_message] = "You have been logged in!"
    else
      @error = true 
      status 422
      erb :home
      session[:error_message] = "Login failed. Please try again."
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
    @original_language= params["original_language"]
    @translated_language = params["translated_language"]
    @genre =params["genre"]
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
    if params["email"]
      @admins = User.where(admin: true) + User.where(email: params["email"])
    else
      @admins = User.where(admin: true)
    end
    erb :admin
  end

  patch '/admin/manage' do
    if params["action"] == "enable"
      User.find(params["id"]).update!(admin: true)
      session[:success_message] = "Success! User #{User.find(params["id"]).name}, ID #{params["id"]}, admin privileges GRANTED."
      redirect to ('/admin')
    elsif params["action"] == "disable"
      x = User.find(params["id"]).update!(admin: false)
      session[:success_message] = "Success! User #{User.find(params["id"]).name}, ID #{params["id"]}, admin privileges REVOKED."
      redirect to('/admin')
    else
      session[:error_message] = "There was an error updating admin privileges for User ID #{params["id"]}. Please try again."
      redirect to('/admin')
    end
  end

  get '/create_account' do
    redirect to('/admin')
  end

  post '/create_account' do
    begin 
      session[:temp_password] = make_password
      x = User.create_user(params["name"], params["email"], session[:temp_password])
      session[:success_message] = "User account for #{x.name} created succesfully. Account ID is #{x.id}. Email did NOT send :("
      m = Mandrill::API.new(ENV.fetch "MANDRILL_APIKEY")
      if m.messages.send(x.welcome_email(session[:temp_password]))
        session[:success_message] = "User account for #{x.name} created succesfully. Account ID is #{x.id}. Email is sent to #{x.email}!"
        redirect to('/admin')
      end
    rescue 
      session[:error_message] = "User creation failed. Please try again."
    ensure 
      session.delete(:temp_password)
      redirect to('/admin')
    end
  end

  #COMMENT ROUTES
  patch '/comment' do
    if params["action"] = "upvote"
      Comment.find(params["comment_id"]).upvote!
    elsif params["action"] = "downvote"
      Comment.find(params["comment_id"]).downvote!
    end
  end

  post '/comment' do
    current_user.comment(params["item_id"], params["comment"])
    redirect back
  end

  post '/translate' do
    @original_text = params["text"]
    @target_language = params["lang"]
    @translation = Yandex.translate(params["text"],params["lang"])
    if @translation
      erb :create_item
    else
      session[:error_message] = "That's not possible. Sorry."
      redirect to("/item") 
    end
  end
end

Translator.run! if $PROGRAM_NAME == __FILE__

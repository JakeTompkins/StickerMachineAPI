Rails.application.routes.draw do

  # root to home, for shits and giggles but don't mess with it
  root to: "home#index"

  # post for user token
  post 'user_token' => 'user_token#create'
  
  # sticker routes
  get '/stickers', to: 'stickers#get_stickers', defaults: { format: "json" }
  post '/stickers/save', to: 'stickers#save_sticker', defaults: {format: "json"}
  get '/stickers/favorites', to: 'stickers#get_user_stickers', defaults: {format: "json"}
  delete 'stickers/unfavorite', to: 'stickers#unfavorite'

  # register the user and save to the db
  post '/users', to: 'users#register', defaults: {format: "json"}
end

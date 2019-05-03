Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
  
  get '/stickers', to: 'stickers#get_stickers', defaults: { format: "json" }

  post '/stickers/save', to: 'stickers#save_sticker', defaults: {format: "json"}

  # get 'user/stickers', to: 'stickers#get_user_stickers', as: 'user_stickers', defaults: { format: "json" }
  # get 'user/events', to: 'volunteer_applications#index', as: 'api_v1_user_events'
end

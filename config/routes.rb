Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/stickers', to: 'stickers#get_stickers', defaults: { format: "json" }
end

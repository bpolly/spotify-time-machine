Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'playlists#index'

  resources :playlists do
    resources :playlist_versions, :path => :versions, :as => :versions do
      member do
        post 'save_to_profile'
      end
    end
  end
  resources :artists
  resources :songs

  get '/get_user_authorization', to: 'authorization#get_user_authorization'
  get '/authorization_landing', to: 'authorization#landing'
end

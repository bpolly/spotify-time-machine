Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'playlists#index'

  resources :playlists do
    resources :playlist_versions, :path => :versions, :as => :versions
  end
  resources :artists
  resources :songs
end

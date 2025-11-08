Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post "/signup", to: "users#create", as: :signup
      post "/login", to: "auth#create", as: :login
      post "/google_oauth", to: "auth#google_oauth", as: :google_oauth
      get "/profile", to: "users#profile", as: :profile
      patch "/update_profile", to: "users#update_profile", as: :update_profile
      patch "/update_password", to: "users#update_password", as: :update_password
      delete "/delete_profile", to: "users#delete_profile", as: :delete_profile
      delete "/logout", to: "auth#destroy", as: :logout
      resources :food_places
      get "/my_businesses", to: "food_places#my_businesses", as: :my_businesses
      get "/favorites", to: "food_places#favorites", as: :favorites
      post "/favorite/:id", to: "food_places#toggle_favorite", as: :favorite
    end
  end
end

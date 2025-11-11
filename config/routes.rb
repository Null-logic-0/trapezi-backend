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
      get "/vip_places", to: "food_places#get_vip_places", as: :vip_places
      post "/favorite/:id", to: "food_places#toggle_favorite", as: :favorite

      get "reviews/:id", to: "food_places#get_reviews", as: :reviews
      post "reviews/:id", to: "food_places#create_review", as: :create_review
      patch "reviews/:place_id/:review_id", to: "food_places#update_review", as: :update_review
      delete "reviews/:place_id/:review_id", to: "food_places#delete_review", as: :delete_review
    end
  end
end

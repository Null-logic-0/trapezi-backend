Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post "/signup", to: "users#create", as: :signup
      post "/confirm", to: "users#confirm", as: :confirm
      post "/login", to: "auth#create", as: :login
      post "/login_as_admin", to: "auth#login_as_admin", as: :login_as_admin
      post "/google_oauth", to: "auth#google_oauth", as: :google_oauth
      get "/profile", to: "users#profile", as: :profile
      patch "/update_profile", to: "users#update_profile", as: :update_profile
      patch "/update_password", to: "users#update_password", as: :update_password
      delete "/delete_profile", to: "users#delete_profile", as: :delete_profile
      delete "/logout", to: "auth#destroy", as: :logout
      post "/password_reset_request", to: "auth#password_reset_request", as: :password_reset_request
      post "/password_reset", to: "auth#password_reset", as: :password_reset

      # Food Places

      resources :food_places
      get "/my_businesses", to: "food_places#my_businesses", as: :my_businesses

      get "/vip_places", to: "food_places#get_vip_places", as: :vip_places
      patch "/update_vip/:id", to: "food_places#update_by_admin", as: :update_vip

      get "/search_places", to: "food_places#search_places", as: :search_places
      get "/all_places", to: "food_places#get_places_for_admin", as: :all_places

      post "/favorite/:id", to: "favorites#toggle_favorite", as: :favorite
      get "/favorites", to: "favorites#favorites", as: :favorites

      delete "delete_by_admin/:id", to: "food_places#destroy_by_admin", as: :destroy_by_admin

      # Reviews

      get "reviews/:id", to: "reviews#get_reviews", as: :reviews
      post "reviews/:id", to: "reviews#create_review", as: :create_review
      patch "reviews/:place_id/:review_id", to: "reviews#update_review", as: :update_review
      delete "reviews/:place_id/:review_id", to: "reviews#delete_review", as: :delete_review

      # Blog
      resources :blogs

      # Reports
      get "reports", to: "reports#index", as: :reports
      get "report/:id", to: "reports#show", as: :report
      post "create_report/:id", to: "reports#create", as: :create_report
      patch "update_report/:place_id/:report_id", to: "reports#update", as: :update_report
      delete "destroy_report/:place_id/:report_id", to: "reports#destroy", as: :destroy_report

      # settings
      patch "admin/registration", to: "settings#update_registration", as: :update_registration
      get "admin/registration", to: "settings#get_registration", as: :get_registration

      patch "admin/maintenance", to: "settings#update_maintenance_mode", as: :update_maintenance_mode
      get "admin/maintenance", to: "settings#maintenance_mode", as: :get_maintenance_mode
    end
  end
end

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post "/signup", to: "users#create", as: :signup
      post "/login", to: "auth#create", as: :login
      get "/profile", to: "users#profile", as: :profile
      delete "/logout", to: "auth#destroy", as: :logout
    end
  end
end

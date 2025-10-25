Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      post "/signup", to: "users#create", as: :signup
    end
  end
end

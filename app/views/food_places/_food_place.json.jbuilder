json.extract! food_place, :id, :user_id, :business_name, :description, :category, :address, :latitude, :longitude, :working_schedule, :website, :facebook, :instagram, :tiktok, :created_at, :updated_at
json.url food_place_url(food_place, format: :json)

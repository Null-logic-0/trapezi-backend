json.extract! user, :id, :name, :last_name, :email, :password_digest, :is_admin, :business_owner, :moderator, :created_at, :updated_at
json.url user_url(user, format: :json)

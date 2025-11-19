Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins %w[ http://localhost:3001 http://localhost:5173 https://trapezi.ge https://admin.trapezi.ge ]

    resource "*",
             headers: :any,
             methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
             credentials: true
  end
end

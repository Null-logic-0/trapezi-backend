# TRAPEZI BACKEND README

![alt text](https://img.shields.io/badge/rails-v8.0.0-red.svg)

![alt text](https://img.shields.io/badge/ruby-3.x-red.svg)

![alt text](https://img.shields.io/badge/postgresql-blue.svg)

![alt text](https://img.shields.io/badge/docker-available-blue.svg)

The backend API for the Trapezi platform. Built with Ruby on Rails 8, this application manages user authentication,
location services, payments, and cloud storage. It is containerized with Docker for a seamless development experience.

🚀 Key Features

Authentication: Secure Google Login integration (OAuth2).

Location Services: Geolocation and mapping features powered by the Google Maps API.

Payments: Integrated TBC Checkout for secure transaction processing.

Storage: Cloud file storage for assets and uploads using Amazon S3.

Containerization: Full Docker setup for consistent development and deployment environments.

🛠 Tech Stack

Framework: Ruby on Rails 8

Database: PostgreSQL

Environment: Docker & Docker Compose

Storage: AWS S3 (via Active Storage)

Integrations:

Google OAuth 2.0

Google Maps Platform

TBC Bank Payment Gateway

⚙️ Prerequisites

Before you begin, ensure you have the following installed on your local machine:

Docker

Docker Compose

Git

💻 Getting Started

1. Clone the Repository
   
         code
         Bash
         download
         content_copy
         expand_less
         git clone https://github.com/Null-logic-0/trapezi-backend.git
         cd trapezi-backend
   
3. Environment Configuration

Create a .env file in the root directory. You can copy a sample if one exists, or use the template below:

code
Bash
download
content_copy
expand_less
cp .env.example .env

# OR create manually

touch .env

Required Environment Variables:

Update the .env file with your credentials:

code
Ini
download
content_copy
expand_less

# Database

POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=trapezi_development
POSTGRES_HOST=db

# Rails

RAILS_ENV=development
RAILS_MASTER_KEY=your-key
SECRET_KEY_BASE=your_generated_secret_key
FRONTEND_URL=http://localhost:3001

# AWS S3 (Storage)

AWS_BUCKET_URL=https://your_s3_bucket.s3.us-east-1.amazonaws.com

# Google Integrations

GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_MAPS_API_KEY=your_maps_api_key
GOOGLE_APPLICATION_CREDENTIALS="/Users/User/Desktop/vision-key/your_key.json"

# TBC Payments

TBC_BASE_URL=TBC_base_url_api
TBC_MERCHANT_ID=your_merchant_id
TBC_SECRET_KEY=your_TBC_secret_key

FRONTEND_CHECKOUT_SUCCESS_URL=http://localhost:3001/checkout/success
BACKEND_CALLBACK_URL=https://your.domain.com/api/v1/payments/callback

3. Build and Run with Docker

Since the project is configured for Docker, you can spin up the Rails app and the PostgreSQL database with a single

**DOCKER_IMAGE_URL:**

https://hub.docker.com/r/nospoon1919/trapezi-dev

command:

      code
      Bash
      download
      content_copy
      expand_less
      docker-compose up --build

The server should now be running at http://localhost:3000.

4. Database Setup

Open a new terminal tab (while Docker is running) to create and migrate the database:

# Create the database

      docker-compose exec web rails db:create

# Run migrations

      docker-compose exec web rails db:migrate

# (Optional) Seed data

      docker-compose exec web rails db:seed
🧪 Running Tests

To run the test suite inside the Docker container:

      code
      Bash
      download
      content_copy
      expand_less
      docker-compose exec web bundle exec rspec

# OR if using Minitest

docker-compose exec web rails test
📦 Deployment
Production Setup

Ensure RAILS_ENV is set to production.

Configure your config/database.yml to point to your production RDS or PostgreSQL instance.

Ensure config/storage.yml is set to amazon for production.

Solid Queue / Background Jobs (Rails 8)

If utilizing Rails 8's new Solid Queue, ensure the configuration is enabled in config/solid_queue.yml and the dispatcher
is running in your production Procfile or Docker entrypoint.

💳 Payment Integration (TBC)

This project uses TBC Bank's e-commerce checkout API.

Configuration logic is located in config/initializers/tbc.rb (or equivalent service).

Ensure valid SSL certificates are provided in the environment/production secrets for TBC authentication.

🗺 Google Maps

Maps API usage is restricted by the key provided in GOOGLE_MAPS_API_KEY.

Ensure the API key has permissions enabled for Maps JavaScript API, Geocoding API, and Places API in the Google Cloud
Console.

🤝 Contributing

Contributions are welcome! Please follow these steps:

Fork the project.

Create your feature branch (git checkout -b feature/AmazingFeature).

Commit your changes (git commit -m 'Add some AmazingFeature').

Push to the branch (git push origin feature/AmazingFeature).

Open a Pull Request.

# ⚠️ **License & Legal Notice**

Copyright © 2025 Null-logic-0. All Rights Reserved.
The source code for this project is Source Available for viewing and educational purposes only (e.g., portfolio
demonstration).

## **Terms of Use:**

**No Commercial Use:**

You may not use this source code, in whole or in part, for any commercial purpose.

**No Modification:**

You may not modify, distribute, or create derivative works from this code.

**No Deployment:**
You may not run this application in a production environment without the owner's explicit written permission.

**Regarding GitHub Forks:**

While this repository is hosted publicly on GitHub,
the right to "Fork" granted by GitHub's Terms of Service is strictly limited to viewing and code analysis.
Forking this repository does not grant you a license to use the software.
Any unauthorized use will be considered a violation of copyright law.

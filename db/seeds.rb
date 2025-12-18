require "open-uri"

settings = [
  { key: "maintenance_mode", value: "false" },
  { key: "registration_enabled", value: "true" }
]

settings.each do |attrs|
  setting = AppSetting.find_or_initialize_by(key: attrs[:key])
  setting.assign_attributes(attrs)
  setting.save!
end

# Clear existing data (optional)
User.destroy_all

puts "Creating sample users..."

# Admin users
User.create!(
  name: "Luka",
  last_name: "Tchelidze",
  email: "chelidze.2011@gmail.com",
  password: "password123",
  password_confirmation: "password123",
  is_admin: true,
  confirmed: true

)

User.create!(
  name: "Paul",
  last_name: "Admin",
  email: "paul.admin@example.com",
  password: "password123",
  password_confirmation: "password123",
  is_admin: true,
  confirmed: true

)

# Moderators
User.create!(
  name: "Charlie",
  last_name: "Mod",
  email: "charlie.mod@example.com",
  password: "password123",
  password_confirmation: "password123",
  moderator: true,
  confirmed: true

)

User.create!(
  name: "Diana",
  last_name: "Mod",
  email: "diana.mod@example.com",
  password: "password123",
  password_confirmation: "password123",
  moderator: true,
  confirmed: true

)

# Owners / Business users
User.create!(
  name: "Eva",
  last_name: "Owner",
  email: "eva.owner@example.com",
  password: "password123",
  password_confirmation: "password123",
  business_owner: true,
  confirmed: true,
  plan: "pro"

)

User.create!(
  name: "David",
  last_name: "Owner",
  email: "david.owner@example.com",
  password: "password123",
  password_confirmation: "password123",
  business_owner: true,
  confirmed: true,
  plan: "pro"

)

User.create!(
  name: "Nick",
  last_name: "Owner",
  email: "nick.owner@example.com",
  password: "password123",
  password_confirmation: "password123",
  business_owner: true,
  confirmed: true,
  plan: "pro"

)

# Regular users
User.create!(
  name: "Gorge",
  last_name: "User",
  email: "gorge.user@example.com",
  password: "password123",
  password_confirmation: "password123",
  confirmed: true
)

User.create!(
  name: "Elene",
  last_name: "User",
  email: "elene.user@example.com",
  password: "password123",
  password_confirmation: "password123",
  confirmed: true

)

# Blocked users
User.create!(
  name: "salome",
  last_name: "Blocked",
  email: "salome.blocked@example.com",
  password: "password123",
  password_confirmation: "password123",
  is_blocked: true,
  confirmed: true

)

User.create!(
  name: "Ana",
  last_name: "Blocked",
  email: "ana.blocked@example.com",
  password: "password123",
  password_confirmation: "password123",
  is_blocked: true,
  confirmed: true

)

puts "Created #{User.count} users."

puts "Creating sample food places..."

users = User.all.to_a
if users.empty?
  puts "No users found! Please seed users first."
  exit
end

categories = %W[restaurant pastry bakery bar cafe]

image_urls = %W[
  https://images.unsplash.com/photo-1504674900247-0877df9cc836?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VlfHx8fHx8Mnx8MTY5NjYxNDYwMw&ixlib=rb-4.0.3&q=80&w=1080
  https://images.unsplash.com/photo-1555992336-03a23c68e2f0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VlfHx8fHx8Mnx8MTY5NjYxNDYwMw&ixlib=rb-4.0.3&q=80&w=1080
  https://images.unsplash.com/photo-1551218808-94e220e084d2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VlfHx8fHx8Mnx8MTY5NjYxNDYwMw&ixlib=rb-4.0.3&q=80&w=1080
  https://images.unsplash.com/photo-1541542684-2e2b4307e3f6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VlfHx8fHx8Mnx8MTY5NjYxNDYwMw&ixlib=rb-4.0.3&q=80&w=1080
  https://images.unsplash.com/photo-1498654896293-37aacf113fd9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VlfHx8fHx8Mnx8MTY5NjYxNDYwMw&ixlib=rb-4.0.3&q=80&w=1080
]

pdf_urls = %W[
  https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf
  https://www.orimi.com/pdf-test.pdf
]

vip_plans = %W[1_month 2_weeks 2_days]

10.times do |i|
  owner = users.select(&:business_owner?).sample
  is_vip = [ true, false ].sample
  category = categories.sample(1)

  food_place = nil
  begin
    food_place = FoodPlace.new(
      user: owner,
      business_name: "FoodPlace #{i + 1}",
      description: "Delicious food for everyone!",
      categories: category,
      identification_code: "01010101",
      working_schedule: {
        "monday": { "from": "08:00", "to": "20:00" },
        "tuesday": { "from": "08:00", "to": "20:00" },
        "wednesday": { "from": "08:00", "to": "20:00" },
        "thursday": { "from": "08:00", "to": "20:00" },
        "friday": { "from": "08:00", "to": "22:00" },
        "saturday": { "from": "09:00", "to": "22:00" },
        "sunday": { "from": nil, "to": nil }
      },
      address: "#{i + 1} Main Street",
      phone: "+995123456#{100 + i}",
      is_vip: is_vip,
      vip_plan: is_vip ? vip_plans.sample : nil,
      created_at: rand(1..365).days.ago,
      updated_at: rand(1..365).days.ago
    )

    image_file = URI.open(image_urls.sample)
    food_place.images.attach(io: image_file, filename: "foodPlace_#{i + 1}.jpg")

    document_file = URI.open(pdf_urls.sample)
    food_place.document_pdf.attach(io: document_file, filename: "document_#{i + 1}.pdf")

    menu_file = URI.open(pdf_urls.sample)
    food_place.menu_pdf.attach(io: menu_file, filename: "menu_#{i + 1}.pdf")

    food_place.save!
  rescue ActiveRecord::RecordInvalid => e
    puts "Failed to create FoodPlace #{i + 1}: #{e.record.errors.full_messages.join(', ')}"
  rescue => e
    puts "Unexpected error for FoodPlace #{i + 1}: #{e.message}"
  end
end

puts "Created #{FoodPlace.count} food places."

puts "Creating sample reviews..."

food_places = FoodPlace.all
users = User.all.to_a

if food_places.empty? || users.empty?
  puts "No food places or users found! Please seed users and food places first."
  exit
end

sample_comments = [
  "Amazing food and great service!",
  "Would definitely come again.",
  "The place was okay, nothing special.",
  "Loved the ambiance and the drinks!",
  "Not satisfied with the service.",
  "Delicious desserts, highly recommend!",
  "Average experience, could be better.",
  "Fantastic! Everything was perfect.",
  "I didn't like the menu options.",
  "Very friendly staff and cozy place."
]

food_places.each do |food_place|
  rand(1..5).times do
    user = users.sample

    next if user.is_blocked?

    review = user.reviews.build(
      food_place: food_place,
      rating: rand(1..5),
      comment: sample_comments.sample
    )

    begin
      review.save!
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to create review for FoodPlace #{food_place.id}: #{e.record.errors.full_messages.join(', ')}"
    end
  end
end

puts "Created #{Review.count} reviews."

puts "Creating sample payments..."

users_with_plans = User.where.not(plan: [ nil, "" ]).to_a
if users_with_plans.empty?
  puts "No users with plans found! Please seed users with plans first."
  exit
end

payment_statuses = %w[pending approved failed]
plans = Payment::PLANS.keys

users_with_plans.each do |user|
  rand(1..3).times do
    plan_type = plans.sample
    amount = Payment::PLANS[plan_type][:amount]

    order_id = "ORD-#{Time.now.to_i}-#{SecureRandom.hex(4)}"

    payment = Payment.new(
      user: user,
      resource: user,
      order_id: order_id,
      amount: amount,
      plan_type: plan_type,
      status: payment_statuses.sample,
      created_at: rand(1..365).days.ago,
      updated_at: rand(1..365).days.ago
    )

    begin
      payment.save!
    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to create payment for User #{user.id}: #{e.record.errors.full_messages.join(', ')}"
    end
  end
end

puts "Created #{Payment.count} payments."

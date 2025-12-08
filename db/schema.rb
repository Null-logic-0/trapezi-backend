# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_07_103102) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "app_settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blacklisted_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_blacklisted_tokens_on_token"
  end

  create_table "blogs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "food_place_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_place_id"], name: "index_favorites_on_food_place_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "food_places", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name"
    t.text "description"
    t.string "categories", default: [], null: false, array: true
    t.string "phone"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.jsonb "working_schedule", default: {}
    t.string "website"
    t.string "facebook"
    t.string "instagram"
    t.string "tiktok"
    t.boolean "is_vip", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "vip_expires_at"
    t.boolean "hidden", default: false
    t.boolean "is_open", default: false, null: false
    t.index ["user_id"], name: "index_food_places_on_user_id"
    t.index ["vip_expires_at"], name: "index_food_places_on_vip_expires_at"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "food_place_id", null: false
    t.string "pay_id"
    t.string "status"
    t.integer "amount_cents"
    t.string "currency"
    t.string "duration_key"
    t.jsonb "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_place_id"], name: "index_payments_on_food_place_id"
    t.index ["pay_id"], name: "index_payments_on_pay_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "food_place_id", null: false
    t.string "title"
    t.string "description"
    t.integer "status", default: 0
    t.string "report_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_place_id"], name: "index_reports_on_food_place_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "food_place_id", null: false
    t.string "comment"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_place_id"], name: "index_reviews_on_food_place_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.boolean "is_admin", default: false
    t.boolean "business_owner", default: false
    t.boolean "moderator", default: false
    t.boolean "is_blocked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string "google_uid"
    t.boolean "confirmed", default: false
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.string "plan", default: "free", null: false
    t.integer "strike_count"
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token"
  end

  create_table "video_tutorials", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.float "duration"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_video_tutorials_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blogs", "users"
  add_foreign_key "favorites", "food_places"
  add_foreign_key "favorites", "users"
  add_foreign_key "food_places", "users"
  add_foreign_key "payments", "food_places"
  add_foreign_key "payments", "users"
  add_foreign_key "reports", "food_places"
  add_foreign_key "reports", "users"
  add_foreign_key "reviews", "food_places"
  add_foreign_key "reviews", "users"
  add_foreign_key "video_tutorials", "users"
end

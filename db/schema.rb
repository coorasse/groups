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

ActiveRecord::Schema[8.1].define(version: 2026_07_08_120100) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.decimal "adult_guided_tour_price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "adult_price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "adult_ticket_price", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "kid_guided_tour_price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "kid_price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "kid_ticket_price", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "max_group_size", null: false
    t.integer "max_overbooking", default: 1, null: false
    t.text "message_template"
    t.text "notes"
    t.integer "notify_days_before", default: 2, null: false
    t.string "short_name"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "event_id", null: false
    t.integer "max_group_size"
    t.integer "max_overbooking"
    t.decimal "net_price", precision: 8, scale: 2
    t.text "notes"
    t.integer "notify_days_before"
    t.integer "status", default: 0, null: false
    t.time "time"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_groups_on_event_id"
  end

  create_table "letter_thief_email_messages", force: :cascade do |t|
    t.text "bcc"
    t.text "body_html"
    t.text "body_text"
    t.text "cc"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.text "from"
    t.text "headers"
    t.datetime "intercepted_at"
    t.text "sender"
    t.string "subject"
    t.text "to"
    t.datetime "updated_at", null: false
    t.index ["intercepted_at"], name: "index_letter_thief_email_messages_on_intercepted_at"
  end

  create_table "reservations", force: :cascade do |t|
    t.integer "adults_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.boolean "data_processing_authorized", default: false, null: false
    t.string "email"
    t.string "full_name", null: false
    t.integer "group_id", null: false
    t.integer "guided_tour_only_adults", default: 0, null: false
    t.integer "kids_count", default: 0, null: false
    t.text "notes"
    t.boolean "notified", default: false, null: false
    t.string "phone"
    t.decimal "price_to_pay", precision: 8, scale: 2, null: false
    t.integer "status", default: 2, null: false
    t.string "tax_code"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_reservations_on_group_id"
    t.index ["token"], name: "index_reservations_on_token", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.integer "sys_manager_id", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["sys_manager_id"], name: "index_sessions_on_sys_manager_id"
  end

  create_table "sys_managers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_sys_managers_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "groups", "events"
  add_foreign_key "reservations", "groups"
  add_foreign_key "sessions", "sys_managers"
end

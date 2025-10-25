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

ActiveRecord::Schema[8.0].define(version: 2025_10_19_181201) do
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

  create_table "api_keys", force: :cascade do |t|
    t.string "key"
    t.boolean "active"
    t.text "description"
    t.integer "user_id", null: false
    t.integer "device_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_api_keys_on_device_id"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "authentication_tokens", force: :cascade do |t|
    t.string "auth_device"
    t.string "token_value"
    t.string "nice_name"
    t.string "pin"
    t.boolean "enabled"
    t.datetime "expire_time"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "beverage_producers", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.string "origin_state"
    t.string "origin_city"
    t.boolean "is_homebrew"
    t.string "url"
    t.text "description"
    t.string "beverage_backend"
    t.string "beverage_backend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "beverages", force: :cascade do |t|
    t.string "name"
    t.string "beverage_type"
    t.string "style"
    t.text "description"
    t.date "vintage_year"
    t.float "abv_percent"
    t.float "calories_per_ml"
    t.float "carbs_per_ml"
    t.string "color_hex"
    t.float "original_gravity"
    t.float "specific_gravity"
    t.float "srm"
    t.float "ibu"
    t.float "star_rating"
    t.integer "untappd_beer_id"
    t.string "beverage_backend"
    t.string "beverage_backend_id"
    t.integer "beverage_producer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["beverage_producer_id"], name: "index_beverages_on_beverage_producer_id"
  end

  create_table "devices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drinking_sessions", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.float "volume_ml"
    t.string "timezone"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drinks", force: :cascade do |t|
    t.integer "ticks"
    t.float "volume_ml"
    t.datetime "time"
    t.integer "duration"
    t.text "shout"
    t.text "tick_time_series"
    t.integer "user_id", null: false
    t.integer "keg_id", null: false
    t.integer "drinking_session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drinking_session_id"], name: "index_drinks_on_drinking_session_id"
    t.index ["keg_id"], name: "index_drinks_on_keg_id"
    t.index ["user_id"], name: "index_drinks_on_user_id"
  end

  create_table "flow_meters", force: :cascade do |t|
    t.string "port_name"
    t.float "ticks_per_ml"
    t.integer "controller_id", null: false
    t.integer "keg_tap_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller_id", "port_name"], name: "index_flow_meters_on_controller_id_and_port_name", unique: true
    t.index ["controller_id"], name: "index_flow_meters_on_controller_id"
    t.index ["keg_tap_id"], name: "index_flow_meters_on_keg_tap_id"
  end

  create_table "flow_toggles", force: :cascade do |t|
    t.string "port_name"
    t.integer "controller_id", null: false
    t.integer "keg_tap_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller_id", "port_name"], name: "index_flow_toggles_on_controller_id_and_port_name", unique: true
    t.index ["controller_id"], name: "index_flow_toggles_on_controller_id"
    t.index ["keg_tap_id"], name: "index_flow_toggles_on_keg_tap_id"
  end

  create_table "hardware_controllers", force: :cascade do |t|
    t.string "name"
    t.string "controller_model_name"
    t.string "serial_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.string "invite_code"
    t.string "for_email"
    t.datetime "invited_date"
    t.datetime "expires_date"
    t.integer "invited_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
  end

  create_table "keg_taps", force: :cascade do |t|
    t.string "name"
    t.text "notes"
    t.integer "sort_order"
    t.integer "current_keg_id"
    t.integer "temperature_sensor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "meter_id"
    t.index ["current_keg_id"], name: "index_keg_taps_on_current_keg_id"
    t.index ["meter_id"], name: "index_keg_taps_on_meter_id"
    t.index ["temperature_sensor_id"], name: "index_keg_taps_on_temperature_sensor_id"
  end

  create_table "kegboard_configs", force: :cascade do |t|
    t.string "name", null: false
    t.string "config_type", default: "mqtt", null: false
    t.string "mqtt_broker"
    t.integer "mqtt_port", default: 1883
    t.string "mqtt_username"
    t.string "mqtt_password"
    t.string "mqtt_topic_prefix", default: "kegbot"
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_kegboard_configs_on_enabled"
    t.index ["name"], name: "index_kegboard_configs_on_name", unique: true
  end

  create_table "kegbot_sites", force: :cascade do |t|
    t.string "name"
    t.string "server_version"
    t.boolean "is_setup"
    t.text "registration_id"
    t.string "volume_display_units"
    t.string "temperature_display_units"
    t.string "title"
    t.string "google_analytics_id"
    t.integer "session_timeout_minutes"
    t.string "privacy"
    t.string "registration_mode"
    t.string "timezone"
    t.boolean "enable_sensing"
    t.boolean "enable_users"
    t.text "email_config"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kegs", force: :cascade do |t|
    t.string "keg_type"
    t.float "served_volume_ml"
    t.float "full_volume_ml"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "status"
    t.text "description"
    t.float "spilled_ml"
    t.text "notes"
    t.integer "beverage_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "keg_tap_id"
    t.index ["beverage_id"], name: "index_kegs_on_beverage_id"
    t.index ["keg_tap_id"], name: "index_kegs_on_keg_tap_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.boolean "keg_tapped"
    t.boolean "session_started"
    t.boolean "keg_volume_low"
    t.boolean "keg_ended"
    t.string "backend"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.text "caption"
    t.datetime "time"
    t.integer "user_id"
    t.integer "keg_id"
    t.integer "drinking_session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "drink_id"
    t.index ["drink_id"], name: "index_pictures_on_drink_id"
    t.index ["drinking_session_id"], name: "index_pictures_on_drinking_session_id"
    t.index ["keg_id"], name: "index_pictures_on_keg_id"
    t.index ["user_id"], name: "index_pictures_on_user_id"
  end

  create_table "plugin_data", force: :cascade do |t|
    t.string "plugin_name"
    t.string "key"
    t.json "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stats", force: :cascade do |t|
    t.datetime "time"
    t.json "stats"
    t.boolean "is_first"
    t.integer "user_id", null: false
    t.integer "keg_id", null: false
    t.integer "drinking_session_id", null: false
    t.integer "drink_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drink_id"], name: "index_stats_on_drink_id"
    t.index ["drinking_session_id"], name: "index_stats_on_drinking_session_id"
    t.index ["keg_id"], name: "index_stats_on_keg_id"
    t.index ["user_id"], name: "index_stats_on_user_id"
  end

  create_table "system_events", force: :cascade do |t|
    t.string "kind"
    t.datetime "time"
    t.integer "user_id"
    t.integer "drink_id"
    t.integer "keg_id"
    t.integer "drinking_session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drink_id"], name: "index_system_events_on_drink_id"
    t.index ["drinking_session_id"], name: "index_system_events_on_drinking_session_id"
    t.index ["keg_id"], name: "index_system_events_on_keg_id"
    t.index ["user_id"], name: "index_system_events_on_user_id"
  end

  create_table "thermo_sensors", force: :cascade do |t|
    t.string "raw_name"
    t.string "nice_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thermologs", force: :cascade do |t|
    t.float "temp"
    t.datetime "time"
    t.integer "thermo_sensor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thermo_sensor_id"], name: "index_thermologs_on_thermo_sensor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.string "display_name"
    t.string "mugshot"
    t.string "activation_key"
    t.boolean "is_staff"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_keys", "devices"
  add_foreign_key "api_keys", "users"
  add_foreign_key "authentication_tokens", "users"
  add_foreign_key "beverages", "beverage_producers"
  add_foreign_key "drinks", "drinking_sessions"
  add_foreign_key "drinks", "kegs"
  add_foreign_key "drinks", "users"
  add_foreign_key "flow_meters", "hardware_controllers", column: "controller_id"
  add_foreign_key "flow_meters", "keg_taps"
  add_foreign_key "flow_toggles", "hardware_controllers", column: "controller_id"
  add_foreign_key "flow_toggles", "keg_taps"
  add_foreign_key "invitations", "invited_bies"
  add_foreign_key "keg_taps", "flow_meters", column: "meter_id"
  add_foreign_key "keg_taps", "kegs", column: "current_keg_id"
  add_foreign_key "keg_taps", "thermo_sensors", column: "temperature_sensor_id"
  add_foreign_key "kegs", "beverages"
  add_foreign_key "kegs", "keg_taps"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "pictures", "drinking_sessions"
  add_foreign_key "pictures", "drinks"
  add_foreign_key "pictures", "kegs"
  add_foreign_key "pictures", "users"
  add_foreign_key "stats", "drinking_sessions"
  add_foreign_key "stats", "drinks"
  add_foreign_key "stats", "kegs"
  add_foreign_key "stats", "users"
  add_foreign_key "system_events", "drinking_sessions"
  add_foreign_key "system_events", "drinks"
  add_foreign_key "system_events", "kegs"
  add_foreign_key "system_events", "users"
  add_foreign_key "thermologs", "thermo_sensors"
end

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

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "store_id", null: false
    t.uuid "user_id"
    t.string "action", null: false
    t.string "resource_type", null: false
    t.uuid "resource_id", null: false
    t.jsonb "changes", default: {}
    t.jsonb "metadata", default: {}
    t.inet "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["store_id", "action"], name: "index_audit_logs_on_store_id_and_action"
    t.index ["store_id", "resource_type", "resource_id"], name: "index_audit_logs_on_store_id_and_resource_type_and_resource_id"
    t.index ["store_id"], name: "index_audit_logs_on_store_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "fulfillments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.uuid "location_id"
    t.string "status", default: "pending"
    t.string "tracking_company"
    t.string "tracking_number"
    t.string "tracking_url"
    t.datetime "shipped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_fulfillments_on_location_id"
    t.index ["order_id"], name: "index_fulfillments_on_order_id"
  end

  create_table "inventory_alerts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "store_id", null: false
    t.uuid "variant_id", null: false
    t.uuid "location_id", null: false
    t.integer "threshold", null: false
    t.integer "current_level", null: false
    t.boolean "reviewed", default: false
    t.uuid "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_inventory_alerts_on_location_id"
    t.index ["reviewed_by_id"], name: "index_inventory_alerts_on_reviewed_by_id"
    t.index ["store_id", "reviewed"], name: "index_inventory_alerts_on_store_id_and_reviewed"
    t.index ["store_id"], name: "index_inventory_alerts_on_store_id"
    t.index ["variant_id"], name: "index_inventory_alerts_on_variant_id"
  end

  create_table "inventory_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "variant_id", null: false
    t.uuid "location_id", null: false
    t.integer "available", default: 0, null: false
    t.integer "committed", default: 0, null: false
    t.integer "incoming", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_inventory_levels_on_available"
    t.index ["location_id"], name: "index_inventory_levels_on_location_id"
    t.index ["variant_id", "location_id"], name: "index_inventory_levels_on_variant_id_and_location_id", unique: true
    t.index ["variant_id"], name: "index_inventory_levels_on_variant_id"
  end

  create_table "line_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.uuid "variant_id", null: false
    t.string "title", null: false
    t.string "variant_title"
    t.string "sku"
    t.integer "quantity", default: 1, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "total_discount", precision: 10, scale: 2, default: "0.0"
    t.boolean "requires_shipping", default: true
    t.integer "fulfilled_quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["variant_id"], name: "index_line_items_on_variant_id"
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "store_id", null: false
    t.string "name", null: false
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "province"
    t.string "country", default: "US"
    t.string "zip"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_locations_on_store_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "store_id", null: false
    t.string "order_number", null: false
    t.string "email"
    t.string "status", default: "pending"
    t.string "fulfillment_status", default: "unfulfilled"
    t.string "financial_status", default: "pending"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_tax", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_shipping", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 10, scale: 2, default: "0.0"
    t.string "currency", default: "USD"
    t.jsonb "shipping_address", default: {}
    t.jsonb "billing_address", default: {}
    t.string "idempotency_key"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["idempotency_key"], name: "index_orders_on_idempotency_key", unique: true
    t.index ["store_id", "fulfillment_status"], name: "index_orders_on_store_id_and_fulfillment_status"
    t.index ["store_id", "order_number"], name: "index_orders_on_store_id_and_order_number", unique: true
    t.index ["store_id", "status"], name: "index_orders_on_store_id_and_status"
    t.index ["store_id"], name: "index_orders_on_store_id"
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "store_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "draft"
    t.string "product_type"
    t.string "vendor"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "status"], name: "index_products_on_store_id_and_status"
    t.index ["store_id", "title"], name: "index_products_on_store_id_and_title"
    t.index ["store_id"], name: "index_products_on_store_id"
  end

  create_table "store_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "store_id", null: false
    t.uuid "user_id", null: false
    t.string "role", default: "staff", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "user_id"], name: "index_store_memberships_on_store_id_and_user_id", unique: true
    t.index ["store_id"], name: "index_store_memberships_on_store_id"
    t.index ["user_id"], name: "index_store_memberships_on_user_id"
  end

  create_table "stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "low_stock_threshold", default: 10
    t.jsonb "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_stores_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "variants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "product_id", null: false
    t.string "title", null: false
    t.string "sku"
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.integer "position", default: 0
    t.jsonb "option_values", default: {}
    t.boolean "requires_shipping", default: true
    t.decimal "weight", precision: 10, scale: 2
    t.string "weight_unit", default: "kg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["sku"], name: "index_variants_on_sku"
  end

  add_foreign_key "audit_logs", "stores"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "fulfillments", "locations"
  add_foreign_key "fulfillments", "orders"
  add_foreign_key "inventory_alerts", "locations"
  add_foreign_key "inventory_alerts", "stores"
  add_foreign_key "inventory_alerts", "users", column: "reviewed_by_id"
  add_foreign_key "inventory_alerts", "variants"
  add_foreign_key "inventory_levels", "locations"
  add_foreign_key "inventory_levels", "variants"
  add_foreign_key "line_items", "orders"
  add_foreign_key "line_items", "variants"
  add_foreign_key "locations", "stores"
  add_foreign_key "orders", "stores"
  add_foreign_key "products", "stores"
  add_foreign_key "store_memberships", "stores"
  add_foreign_key "store_memberships", "users"
  add_foreign_key "variants", "products"
end

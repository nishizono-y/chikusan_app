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

ActiveRecord::Schema[8.1].define(version: 2026_07_06_051826) do
  create_table "daily_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "death_count"
    t.integer "feed_stock"
    t.integer "feed_usage"
    t.integer "head_count"
    t.integer "livestock_type_id"
    t.text "memo"
    t.datetime "updated_at", null: false
    t.string "vaccine"
    t.index ["date"], name: "index_daily_records_on_date", unique: true
    t.index ["livestock_type_id"], name: "index_daily_records_on_livestock_type_id"
  end

  create_table "feed_orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "memo"
    t.date "ordered_on", null: false
    t.integer "quantity", null: false
    t.string "supplier", null: false
    t.datetime "updated_at", null: false
    t.index ["ordered_on"], name: "index_feed_orders_on_ordered_on"
  end

  create_table "livestock_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_livestock_types_on_name", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 9, scale: 6, null: false
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "shipments", force: :cascade do |t|
    t.decimal "avg_weight"
    t.integer "count"
    t.datetime "created_at", null: false
    t.string "destination"
    t.date "shipped_at"
    t.datetime "updated_at", null: false
  end

  create_table "vaccine_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "head_count"
    t.date "next_due_on"
    t.text "notes"
    t.datetime "updated_at", null: false
    t.date "vaccinated_on", null: false
    t.string "vaccine_name", null: false
    t.index ["vaccinated_on"], name: "index_vaccine_records_on_vaccinated_on"
  end

  add_foreign_key "daily_records", "livestock_types"
end

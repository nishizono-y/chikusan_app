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

ActiveRecord::Schema[8.1].define(version: 2026_06_23_021847) do
  create_table "daily_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "death_count"
    t.integer "feed_stock"
    t.integer "feed_usage"
    t.text "memo"
    t.datetime "updated_at", null: false
    t.string "vaccine"
  end

  create_table "shipments", force: :cascade do |t|
    t.decimal "avg_weight"
    t.integer "count"
    t.datetime "created_at", null: false
    t.string "destination"
    t.date "shipped_at"
    t.datetime "updated_at", null: false
  end
end

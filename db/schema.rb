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

ActiveRecord::Schema[8.1].define(version: 2026_09_25_220533) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "kills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "killer_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "victim_id", null: false
    t.index ["killer_id"], name: "index_kills_on_killer_id"
    t.index ["victim_id"], name: "index_kills_on_victim_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.text "qr_code"
    t.string "status", default: "alive", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "kills", "users", column: "killer_id"
  add_foreign_key "kills", "users", column: "victim_id"
end

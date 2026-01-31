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

ActiveRecord::Schema.define(version: 2026_01_31_051841) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendship_balances", force: :cascade do |t|
    t.bigint "friendship_id", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "owes_to_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["friendship_id", "owes_to_id"], name: "index_friendship_balances_on_friendship_id_and_owes_to_id", unique: true
    t.index ["friendship_id"], name: "index_friendship_balances_on_friendship_id"
    t.index ["owes_to_id"], name: "index_friendship_balances_on_owes_to_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.bigint "user_1_id", null: false
    t.bigint "user_2_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_1_id", "user_2_id"], name: "index_friendships_on_user_1_id_and_user_2_id", unique: true
    t.index ["user_1_id"], name: "index_friendships_on_user_1_id"
    t.index ["user_2_id"], name: "index_friendships_on_user_2_id"
    t.check_constraint "user_1_id < user_2_id", name: "chk_order"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "mobile_number"
    t.datetime "deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "friendship_balances", "friendships"
  add_foreign_key "friendship_balances", "users", column: "owes_to_id"
  add_foreign_key "friendships", "users", column: "user_1_id"
  add_foreign_key "friendships", "users", column: "user_2_id"
end

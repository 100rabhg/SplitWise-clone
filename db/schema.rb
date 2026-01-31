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

ActiveRecord::Schema.define(version: 2026_01_31_063320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "expense_items", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "transaction_id", null: false
    t.string "name", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transaction_id"], name: "index_expense_items_on_transaction_id"
  end

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

  create_table "item_splits", force: :cascade do |t|
    t.bigint "expense_item_id", null: false
    t.bigint "user_id", null: false
    t.bigint "friendship_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expense_item_id"], name: "index_item_splits_on_expense_item_id"
    t.index ["friendship_id"], name: "index_item_splits_on_friendship_id"
    t.index ["user_id"], name: "index_item_splits_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id"
    t.bigint "friendship_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.text "notes"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["friendship_id"], name: "index_transactions_on_friendship_id"
    t.index ["type"], name: "index_transactions_on_type"
    t.index ["user_id"], name: "index_transactions_on_user_id"
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

  add_foreign_key "expense_items", "transactions"
  add_foreign_key "friendship_balances", "friendships"
  add_foreign_key "friendship_balances", "users", column: "owes_to_id"
  add_foreign_key "friendships", "users", column: "user_1_id"
  add_foreign_key "friendships", "users", column: "user_2_id"
  add_foreign_key "item_splits", "expense_items"
  add_foreign_key "item_splits", "friendships"
  add_foreign_key "item_splits", "users"
  add_foreign_key "transactions", "friendships"
  add_foreign_key "transactions", "users"
end

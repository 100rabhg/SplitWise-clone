class CreateFriendships < ActiveRecord::Migration[6.1]
  def change
    create_table :friendships do |t|
      t.references :user_1, null: false, foreign_key: { to_table: :users }
      t.references :user_2, null: false, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :friendships, [:user_1_id, :user_2_id], unique: true

    # Ensure two different users and an ordering invariant
    add_check_constraint :friendships, "user_1_id < user_2_id", name: "chk_order"
  end
end

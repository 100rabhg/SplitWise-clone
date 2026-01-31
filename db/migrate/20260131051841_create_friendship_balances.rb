class CreateFriendshipBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :friendship_balances do |t|
      t.references :friendship, null: false, foreign_key: true
      t.decimal :balance, precision: 10, scale: 2, default: 0, null: false
      t.references :owes_to, null: false, foreign_key: { to_table: :users }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :friendship_balances, [:friendship_id, :owes_to_id], unique: true
  end
end

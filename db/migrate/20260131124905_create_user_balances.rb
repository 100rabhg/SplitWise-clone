class CreateUserBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :user_balances do |t|
      t.references :user, null: false, foreign_key: true
      
      t.decimal :total_due, precision: 10, scale: 2, default: 0, null: false
      t.decimal :total_owed, precision: 10, scale: 2, default: 0, null: false
      t.decimal :net_balance, precision: 10, scale: 2, default: 0, null: false
      
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

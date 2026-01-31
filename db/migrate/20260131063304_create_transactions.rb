class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.string :type, null: false
      t.references :paid_by, foreign_key: { to_table: :users }
      t.references :friendship, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :notes
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :transactions, :type
  end
end

class CreateExpenseItems < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_items do |t|
      t.string :type, null: false
      t.references :transaction, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

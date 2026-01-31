class CreateItemSplits < ActiveRecord::Migration[6.1]
  def change
    create_table :item_splits do |t|
      t.references :expense_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :friendship, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end

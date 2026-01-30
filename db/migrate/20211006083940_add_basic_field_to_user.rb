class AddBasicFieldToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string
    add_column :users, :mobile_number, :string
  end
end

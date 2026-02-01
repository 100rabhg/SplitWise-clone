# frozen_string_literal: true

Fabricator(:expense_item) do
  transaction   { Fabricate(:transaction) }
  type          { 'Item' }
  name          { Faker::Commerce.product_name }
  amount        { Faker::Commerce.price(range: 5.0..50.0) }
end

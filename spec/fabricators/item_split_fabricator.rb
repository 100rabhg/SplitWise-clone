# frozen_string_literal: true

Fabricator(:item_split) do
  expense_item  { Fabricate(:expense_item) }
  user          { Fabricate(:user) }
  friendship    { Fabricate(:friendship) }
  amount        { Faker::Commerce.price(range: 5.0..50.0) }
end

# frozen_string_literal: true

Fabricator(:transaction) do
  user          { Fabricate(:user) }
  type          { 'ExpenseTransaction' }
  amount        { Faker::Commerce.price(range: 10.0..100.0) }
  notes         { Faker::Lorem.sentence }
end

Fabricator(:expense_transaction, from: :transaction) do
  type { 'ExpenseTransaction' }
  # NOTE: amount validation is skipped in tests, set to 0 initially
  amount { 0 }
end

Fabricator(:payment_transaction, from: :transaction) do
  type { 'PaymentTransaction' }
end

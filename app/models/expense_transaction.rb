# frozen_string_literal: true

class ExpenseTransaction < Transaction
  include AmountSumValidatable

  has_many :expense_items, dependent: :destroy

  validates_amount_equals_sum_of :expense_items
end

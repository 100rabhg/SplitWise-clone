# frozen_string_literal: true

class ExpenseItem < ApplicationRecord
  include AmountSumValidatable
  acts_as_paranoid

  belongs_to :expense_transaction, foreign_key: :transaction_id, touch: true
  has_many :item_splits, dependent: :destroy
  accepts_nested_attributes_for :item_splits,
                                allow_destroy: true

  validates :amount, presence: true, numericality: { greater_than: 0 }

  validates_amount_equals_sum_of :item_splits
end

# frozen_string_literal: true

class ExpenseItem < ApplicationRecord
  include AmountSumValidatable
  acts_as_paranoid

  belongs_to :transaction
  has_many :item_splits, dependent: :destroy

  validates :amount, presence: true, numericality: { greater_than: 0 }

  validates_amount_equals_sum_of :item_splits
end

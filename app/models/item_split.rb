# frozen_string_literal: true

class ItemSplit < ApplicationRecord
  acts_as_paranoid

  belongs_to :expense_item
  belongs_to :user
  belongs_to :friendship

  validates :amount, presence: true, numericality: { greater_than: 0 }
end

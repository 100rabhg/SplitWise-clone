# frozen_string_literal: true

class Transaction < ApplicationRecord
  acts_as_paranoid

  validates :amount, presence: true, numericality: { greater_than: 0 }

  belongs_to :paid_by, class_name: 'User'
end

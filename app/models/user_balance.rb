# frozen_string_literal: true

class UserBalance < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  # Validations
  validates :total_due, :total_owed, :net_balance, presence: true, numericality: true
  validates :user_id, presence: true, uniqueness: true
end

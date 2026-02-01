# frozen_string_literal: true

class FlatFriendship < ApplicationRecord
  acts_as_paranoid

  has_many :payment_transactions
  has_many :friendship_balances
  has_many :item_splits
  belongs_to :friend, class_name: 'User'
end

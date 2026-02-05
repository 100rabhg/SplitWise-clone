# frozen_string_literal: true

class FlatFriendship < ApplicationRecord
  self.primary_key = :id
  acts_as_paranoid

  has_many :payment_transactions, foreign_key: :friendship_id
  has_one :friendship_balance, foreign_key: :friendship_id
  has_many :item_splits, foreign_key: :friendship_id
  belongs_to :friend, class_name: 'User'
end

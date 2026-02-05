# frozen_string_literal: true

class ItemSplit < ApplicationRecord
  acts_as_paranoid

  belongs_to :expense_item, touch: true
  belongs_to :user
  belongs_to :friendship, optional: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  before_validation :add_friendship
  validates :friendship_id, presence: true, if: -> { expense_item.expense_transaction.paid_by_id != user_id }

  def add_friendship
    return if expense_item.expense_transaction.paid_by_id == user_id

    self.friendship_id = FlatFriendship.find_by(
      user_id: expense_item.expense_transaction.paid_by_id, friend_id: user_id
    )&.id
  end
end

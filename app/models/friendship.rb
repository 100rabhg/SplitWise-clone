# frozen_string_literal: true

class Friendship < ApplicationRecord
  acts_as_paranoid

  belongs_to :user1, class_name: 'User', foreign_key: :user_1_id
  belongs_to :user2, class_name: 'User', foreign_key: :user_2_id

  has_many :payment_transactions, dependent: :destroy
  has_many :friendship_balances, dependent: :destroy
  has_many :item_splits, dependent: :destroy

  validate :users_are_different
  validates :user_1_id, uniqueness: { scope: :user_2_id }

  before_validation :normalize_user_ids

  def users
    [user1, user2]
  end

  private

  def users_are_different
    errors.add(:user_2_id, 'cannot be the same as user_1') if user_1_id == user_2_id
  end

  def normalize_user_ids
    return if user_1_id.blank? || user_2_id.blank?

    self.user_1_id, self.user_2_id = [user_1_id.to_i, user_2_id.to_i].minmax
  end
end

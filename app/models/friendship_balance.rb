# frozen_string_literal: true

class FriendshipBalance < ApplicationRecord
  acts_as_paranoid

  belongs_to :friendship
  belongs_to :owes_to, class_name: 'User'

  validates :balance, presence: true, numericality: true
  validates :owes_to_id, presence: true, uniqueness: { scope: :friendship_id }

  # Callbacks to trigger user balance recalculation
  after_commit :trigger_user_balance_recalculation, on: %i[create update]

  scope :for_user, lambda { |user_id|
    joins(:friendship)
      .where(
        'friendships.user_1_id = :id OR friendships.user_2_id = :id',
        id: user_id
      )
  }

  private

  # Trigger recalculation for both users in the friendship
  def trigger_user_balance_recalculation
    # Recalculate for user_1
    UserBalanceRecalculationJob.perform_later(friendship.user_1_id)
    # Recalculate for user_2
    UserBalanceRecalculationJob.perform_later(friendship.user_2_id)
  end
end

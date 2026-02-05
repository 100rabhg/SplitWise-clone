# frozen_string_literal: true

class RecalculateFriendshipBalanceJob < ApplicationJob
  queue_as :default

  attr_accessor :friendship, :user, :friend

  def perform(friendship_id)
    self.friendship = Friendship.find_by(id: friendship_id)
    return unless friendship

    self.user = friendship.user1
    self.friend = friendship.user2

    upsert_balance
  end

  private

  def net_balance
    expense_net + settlement_net
  end

  # (what friend owes user) - (what user owes friend)
  def expense_net
    shares_paid_by(user, friend) - shares_paid_by(friend, user)
  end

  def settlement_net
    # settlements paid - settlements received
    total_paid_by(user) - total_paid_by(friend)
  end

  def shares_paid_by(payer, consumer)
    ItemSplit
      .joins(expense_item: :expense_transaction)
      .where(
        user_id: consumer.id, friendship_id: friendship.id,
        transactions: { paid_by_id: payer.id }
      )
      .sum(:amount).to_f
  end

  def total_paid_by(payer)
    PaymentTransaction.where(paid_by_id: payer.id, friendship_id: friendship.id).sum(:amount).to_f
  end

  def upsert_balance
    FriendshipBalance.transaction do
      balance = FriendshipBalance.lock.find_or_create_by!(friendship: friendship)
      net = net_balance
      balance.update!(balance: net.abs, owes_to: net.positive? ? user : friend)
    end
  end
end

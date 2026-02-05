# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :set_friendships, only: %i[index person activity]

  def index
    @balance = current_user.ensure_balance
    load_friendship_balances
  end

  def person
    @friend = User.find(params[:id])
    @friendship = find_friendship(@friend)

    redirect_to new_friendship_path, alert: 'Add as friend to view details.' and return unless @friendship

    load_friendship_balances
    load_friend_transactions(@friendship)
    @friendship_balance = FriendshipBalance.find_by(friendship_id: @friendship.id)
  end

  def activity
    @transactions = current_user.activity_transactions.includes(:paid_by)
  end

  private

  def set_friendships
    @friendships = current_user.friendships.includes(:friend, :friendship_balance)
  end

  def load_friendship_balances
    scope = current_user.friendship_balances
                        .where('balance > 0')
                        .includes(friendship: %i[user1 user2])

    @you_owe = scope.where.not(owes_to_id: current_user.id)
    @owed_to_you = scope.where(owes_to_id: current_user.id)
  end

  def find_friendship(friend)
    FlatFriendship.find_by(user_id: current_user.id, friend_id: friend.id)
  end

  def load_friend_transactions(friendship)
    expenses = ExpenseTransaction
               .joins(expense_items: :item_splits)
               .where(item_splits: { friendship_id: friendship.id })
               .distinct
               .includes(:paid_by)

    payments = PaymentTransaction.where(friendship_id: friendship.id)

    @transactions = (expenses.to_a + payments.to_a).sort_by(&:created_at).reverse
  end
end

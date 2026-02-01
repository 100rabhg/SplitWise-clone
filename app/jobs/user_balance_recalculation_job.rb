# frozen_string_literal: true

class UserBalanceRecalculationJob < ApplicationJob
  queue_as :default

  attr_accessor :user

  BALANCE_SUM_SQL = <<~SQL
    SUM(
      CASE
        WHEN friendship_balances.owes_to_id = :uid
        THEN friendship_balances.balance
        ELSE 0
      END
    ) AS total_due,
    SUM(
      CASE
        WHEN friendship_balances.owes_to_id != :uid
        THEN friendship_balances.balance
        ELSE 0
      END
    ) AS total_owed
  SQL

  def perform(user_id)
    self.user = User.find_by(id: user_id)
    return unless user

    recalculate_from_friendships
  end

  def recalculate_from_friendships
    balances = calculate_balances
    balance = user.ensure_balance

    balance.total_due = balances[:total_due]
    balance.total_owed = balances[:total_owed]
    balance.net_balance = balances[:net_balance]
    balance.save!
  end

  def calculate_balances
    # Aggregate all friendship balances
    friendship_balances = FriendshipBalance.for_user(user.id)
    result = friendship_balances.select(FriendshipBalance.sanitize_sql([BALANCE_SUM_SQL, { uid: user.id }])).take

    total_due  = result.total_due.to_f
    total_owed = result.total_owed.to_f

    { total_due: total_due, total_owed: total_owed, net_balance: total_due - total_owed }
  end
end

# frozen_string_literal: true

module ApplicationHelper
  def net_amount_for_friend(current_user, friend_balance)
    return 0 unless friend_balance

    friend_balance.owes_to_id == current_user.id ? friend_balance.balance : -friend_balance.balance
  end

  def friend_net_badge(current_user, balance)
    net = net_amount_for_friend(current_user, balance).to_f

    if net.zero?
      content_tag(:span, 'settled', class: 'badge text-secondary')
    else
      cls = net.positive? ? 'badge badge-success' : 'badge badge-danger'
      content_tag(:span, number_to_currency(net.abs), class: cls)
    end
  end

  def edit_path_for(transaction)
    transaction.is_a?(PaymentTransaction) ? edit_payment_path(transaction) : edit_expense_path(transaction)
  end

  def transaction_path(transaction)
    transaction.is_a?(PaymentTransaction) ? payment_path(transaction) : expense_path(transaction)
  end

  def user_share_for_transaction(transaction, user, friend: nil)
    if transaction.is_a?(PaymentTransaction)
      calculate_payment_share(transaction, user)
    else
      calculate_expense_share(transaction, user, friend)
    end
  end

  def calculate_payment_share(transaction, user)
    transaction.paid_by_id == user.id ? transaction.amount : -transaction.amount
  end

  def calculate_expense_share(transaction, user, friend)
    # If a friend context is provided, calculate share between user and friend
    return calculate_friend_context_share(transaction, user, friend) if friend

    # Otherwise, calculate user's global share in the transaction
    calculate_global_share(transaction, user)
  end

  # Calculates the net share between user and friend for a transaction.
  # Positive: friend owes user. Negative: user owes friend. Zero: no direct debt.
  def calculate_friend_context_share(transaction, user, friend)
    if transaction.paid_by_id == user.id
      total_splits_for(transaction, friend.id)
    elsif transaction.paid_by_id == friend.id
      -total_splits_for(transaction, user.id)
    else
      0
    end
  end

  # Calculates user's share in a transaction without friend context.
  def calculate_global_share(transaction, user)
    user_split_amount = total_splits_for(transaction, user.id)

    if transaction.paid_by_id == user.id
      transaction.amount - user_split_amount
    else
      -user_split_amount
    end
  end

  def total_splits_for(transaction, user_id)
    transaction.expense_items
               .joins(:item_splits)
               .where(item_splits: { user_id: user_id })
               .sum('item_splits.amount')
  end

  def transaction_share_badge(transaction, user, friend: nil)
    share = user_share_for_transaction(transaction, user, friend: friend)

    if share.zero?
      content_tag(:span, number_to_currency(share.abs), class: 'badge bg-secondary')
    elsif share.positive?
      content_tag(:span, number_to_currency(share.abs), class: 'badge bg-success')
    else
      content_tag(:span, number_to_currency(share.abs), class: 'badge bg-danger')
    end
  end
end

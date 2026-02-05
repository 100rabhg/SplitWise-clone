# frozen_string_literal: true

class FriendshipsController < ApplicationController
  def new; end

  def create
    email = params[:email].to_s.strip.downcase
    return render_error('Please enter a valid email.') if email.blank?

    friend = User.find_by(email: email)
    return render_error('No user found with that email.') if friend.nil?
    return render_error('You cannot add yourself as a friend.') if friend.id == current_user.id

    process_friendship_creation(friend)
  end

  def destroy
    friendship = Friendship.user_friendships(current_user.id).find(params[:id])

    if friendship
      destroy_friendship_with_cleanup(friendship)
      redirect_to root_path, notice: 'Friendship removed.'
    else
      redirect_to root_path, alert: 'Friendship not found.'
    end
  end

  private

  def render_error(msg)
    flash.now[:alert] = msg
    render :new
  end

  def process_friendship_creation(friend)
    id1, id2 = [current_user.id, friend.id].minmax
    friendship = Friendship.with_deleted.find_by(user_1_id: id1, user_2_id: id2)

    return restore_friendship(friendship, friend) if friendship&.deleted?

    return redirect_to "/people/#{friend.id}", notice: 'Friendship already exists.' if friendship

    create_new_friendship(id1, id2, friend)
  end

  def restore_friendship(friendship, friend)
    friendship.recover(recursive: false)
    FriendshipBalance.only_deleted.find_by(friendship_id: friendship.id)&.update(deleted_at: nil, balance: 0)
    redirect_to "/people/#{friend.id}", notice: 'Friendship restored successfully.'
  end

  def create_new_friendship(user_one_id, user_two_id, friend)
    friendship = Friendship.new(user_1_id: user_one_id, user_2_id: user_two_id)
    if friendship.save
      redirect_to "/people/#{friend.id}", notice: 'Friend added successfully.'
    else
      flash.now[:alert] = friendship.errors.full_messages.to_sentence.presence || 'Could not add friend.'
      render :new
    end
  end

  def destroy_friendship_with_cleanup(friendship)
    # Capture related expense transactions prior to destroy
    expense_tx_ids = fetch_related_expense_ids(friendship)

    friendship.destroy

    cleanup_orphan_expenses(expense_tx_ids)
  end

  def fetch_related_expense_ids(friendship)
    ExpenseTransaction
      .joins(expense_items: :item_splits)
      .where(item_splits: { friendship_id: friendship.id })
      .distinct
      .pluck(:id)
  end

  def cleanup_orphan_expenses(expense_tx_ids)
    expense_tx_ids.each do |tx_id|
      tx = ExpenseTransaction.find_by(id: tx_id)
      next unless tx

      has_splits = ExpenseItem
                   .joins(:item_splits)
                   .where(transaction_id: tx.id)
                   .exists?
      tx.destroy unless has_splits
    end
  end
end

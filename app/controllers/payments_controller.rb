# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update destroy]
  before_action :authorize_participant!, only: %i[show edit update destroy]

  def new
    @payment = PaymentTransaction.new
    @friends = current_user.friends
    @payer_options = [[current_user.name, current_user.id]]

    handle_friend_param if params[:friend_id].present?
  end

  def create
    @payment = PaymentTransaction.new(payment_params)
    set_friendship_if_present

    if @payment.save
      redirect_to root_path, notice: 'Payment recorded.'
    else
      prepare_form_data
      render :new
    end
  end

  def destroy
    @payment.destroy
    redirect_to root_path, notice: 'Payment deleted successfully.'
  end

  def edit
    @friends = current_user.friends
    prepare_payer_options(@payment.friendship)
  end

  def update
    if @payment.update(payment_params)
      redirect_to root_path, notice: 'Payment updated.'
    else
      @friends = current_user.friends
      prepare_payer_options(@payment.friendship)
      render :edit
    end
  end

  def show
    prepare_payer_options(@payment.friendship)
  end

  private

  def payment_params
    params.require(:payment_transaction).permit(:amount, :notes, :paid_by_id)
  end

  def set_payment
    @payment = PaymentTransaction.find(params[:id])
  end

  def authorize_participant!
    friendship = @payment.friendship
    user_ids = [friendship.user_1_id, friendship.user_2_id]
    return if user_ids.include?(current_user.id)

    redirect_to root_path, alert: 'You are not allowed to view this payment.'
  end

  def handle_friend_param
    @friend = User.find(params[:friend_id])
    friendship = FlatFriendship.find_by(user_id: current_user.id, friend_id: @friend.id)
    balance = friendship&.friendship_balance

    calculate_initial_amounts(balance) if balance
    @payer_options << [@friend.name, @friend.id]
  end

  def calculate_initial_amounts(balance)
    net_amount = balance.owes_to_id == current_user.id ? balance.balance : -balance.balance

    if net_amount.positive?
      @payment.paid_by_id = @friend.id
      @payment.amount = net_amount
    else
      @payment.paid_by_id = current_user.id
      @payment.amount = net_amount.abs
    end
  end

  def set_friendship_if_present
    friend_id = params[:payment_transaction][:friend_id]
    return unless friend_id.present?

    @friendship = FlatFriendship.find_by(user_id: current_user.id, friend_id: friend_id)
    if @friendship.present?
      @payment.friendship_id = @friendship.id
    else
      flash.now[:alert] = 'Friend not found.'
      render :new
    end
  end

  def prepare_form_data
    @friends = current_user.friends
    @payer_options = [[current_user.name, current_user.id]]
    friend_id = params[:payment_transaction][:friend_id]
    return unless friend_id.present?

    friend = User.find(friend_id)
    @payer_options << [friend.name, friend.id]
    @friend = friend
  end

  def prepare_payer_options(friendship)
    friend_id = friendship.user_1_id == current_user.id ? friendship.user_2_id : friendship.user_1_id
    friend = User.find(friend_id)
    @payer_options = [[current_user.name, current_user.id], [friend.name, friend.id]]
    @friend = friend
  end
end

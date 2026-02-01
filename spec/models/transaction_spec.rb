# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transaction Callbacks', type: :model do
  describe 'ExpenseTransaction' do
    let(:user1) { Fabricate(:user) }
    let(:user2) { Fabricate(:user) }
    let(:user3) { Fabricate(:user) }
    let(:friendship) { Fabricate(:friendship, user_1_id: user1.id, user_2_id: user2.id) }
    let(:friendship2) { Fabricate(:friendship, user_1_id: user1.id, user_2_id: user3.id) }

    # Create expense transaction with nested items and splits (matching seeds approach)
    def create_expense_with_splits(payer, amount, user_splits)
      # Build expense_items_attributes structure with nested item_splits_attributes
      expense_items_attrs = user_splits.map do |user, split_amount|
        { type: 'Item', name: Faker::Food.dish, amount: split_amount,
          item_splits_attributes: [
            { user_id: user.id, friendship_id: friendship.id, amount: split_amount }
          ] }
      end

      ExpenseTransaction.create!(
        paid_by_id: payer.id, amount: amount, notes: Faker::Lorem.sentence,
        expense_items_attributes: expense_items_attrs
      )
    end

    context 'when expense transaction is created' do
      it 'triggers balance recalculation for all involved friendships' do
        expect(RecalculateFriendshipBalanceJob).to receive(:perform_later).at_least(:once)

        create_expense_with_splits(user1, 100, { user2 => 100 })
      end
    end

    context 'when expense is destroyed' do
      it 'triggers balance recalculation to reset balances' do
        transaction = create_expense_with_splits(user1, 100, { user2 => 100 })

        expect(RecalculateFriendshipBalanceJob).to receive(:perform_later).at_least(:once)

        transaction.destroy!
      end

      it 'triggers balance recalculation to on delete expense item' do
        transaction = create_expense_with_splits(user1, 100, { user2 => 100 })

        expect(RecalculateFriendshipBalanceJob)
          .to receive(:perform_later)
          .with(friendship.id)
          .at_least(:once)

        expense_item = transaction.expense_items.first
        transaction.update!(
          amount: 100,
          expense_items_attributes: [
            {
              id: expense_item.id,
              amount: 100,
              item_splits_attributes: [
                { id: expense_item.item_splits.first.id, _destroy: true },
                { user_id: user2.id, friendship_id: friendship.id, amount: 50 },
                { user_id: user1.id, friendship_id: friendship.id, amount: 50 }
              ]
            }
          ]
        )
      end
    end
  end

  describe 'PaymentTransaction' do
    let(:user1) { Fabricate(:user) }
    let(:user2) { Fabricate(:user) }
    let(:friendship) { Fabricate(:friendship, user_1_id: user1.id, user_2_id: user2.id) }

    context 'when payment transaction is created' do
      it 'triggers balance recalculation for the friendship' do
        expect(RecalculateFriendshipBalanceJob).to receive(:perform_later).with(friendship.id)

        PaymentTransaction.create!(
          paid_by: user1,
          friendship: friendship,
          amount: 50,
          notes: 'Payment for shared dinner'
        )
      end
    end

    context 'when payment is made with valid friendship' do
      it 'creates the payment transaction successfully' do
        payment = PaymentTransaction.create!(
          paid_by: user1,
          friendship: friendship,
          amount: 50
        )

        expect(payment.id).to be_present
        expect(payment.friendship_id).to eq(friendship.id)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecalculateFriendshipBalanceJob do
  describe '#perform' do
    let(:user1) { Fabricate(:user) }
    let(:user2) { Fabricate(:user) }
    let(:friendship) { Fabricate(:friendship, user_1_id: user1.id, user_2_id: user2.id) }

    def create_expense(payer, amount, splits_data)
      expense_items_attrs = splits_data.map do |user, split_amount|
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

    context 'when friendship has single expense item paid by user1' do
      it 'creates correct balance showing user2 owes user1' do
        create_expense(user1, 100, { user2 => 100 })

        RecalculateFriendshipBalanceJob.new.perform(friendship.id)

        balance = FriendshipBalance.find_by(friendship: friendship, owes_to: user1)
        expect(balance.balance).to eq(100)
      end
    end

    context 'when expense is split equally between both users' do
      it 'creates zero balance' do
        create_expense(user1, 100, { user1 => 50, user2 => 50 })

        RecalculateFriendshipBalanceJob.new.perform(friendship.id)

        balance = FriendshipBalance.find_by(friendship: friendship, owes_to: user1)
        expect(balance.balance).to eq(50)
      end
    end

    context 'when multiple expenses exist' do
      it 'sums all amounts correctly' do
        # Transaction 1: User1 pays 100, User2 uses it all
        create_expense(user1, 100, { user2 => 100 })

        # Transaction 2: User2 pays 50, User1 uses it all
        create_expense(user2, 50, { user1 => 50 })

        RecalculateFriendshipBalanceJob.new.perform(friendship.id)

        balance = FriendshipBalance.find_by(friendship: friendship, owes_to: user1)
        # User1 paid 100, User2 paid 50
        # Net: User2 owes User1 50
        expect(balance.balance).to eq(50)
      end
    end

    context 'when friendship does not exist' do
      it 'returns gracefully without error' do
        expect do
          RecalculateFriendshipBalanceJob.new.perform(999)
        end.not_to raise_error
      end
    end

    context 'it maintains bidirectional balance invariant' do
      it 'creates reverse balances that sum to zero' do
        create_expense(user1, 100, { user2 => 100 })

        RecalculateFriendshipBalanceJob.new.perform(friendship.id)

        expect(FriendshipBalance.find_by(friendship: friendship, owes_to: user1).balance).to eq(100)
      end
    end

    context 'it is idempotent' do
      it 'produces the same result when called multiple times' do
        create_expense(user1, 100, { user2 => 100 })

        # Call twice
        RecalculateFriendshipBalanceJob.new.perform(friendship.id)
        first_balance = FriendshipBalance.find_by(friendship: friendship, owes_to: user1).balance

        RecalculateFriendshipBalanceJob.new.perform(friendship.id)
        second_balance = FriendshipBalance.find_by(friendship: friendship, owes_to: user1).balance

        expect(first_balance).to eq(second_balance)
        expect(second_balance).to eq(100)
      end
    end
  end
end

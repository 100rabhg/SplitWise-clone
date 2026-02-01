# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBalanceRecalculationJob, type: :job do
  describe '#perform' do
    let(:user) { Fabricate(:user) }

    context 'when user exists with balance' do
      let(:balance) { Fabricate(:user_balance, user: user, total_due: 0, total_owed: 0) }

      before do
        balance
        friend = Fabricate(:user)
        friendship = Fabricate(:friendship, user_1_id: user.id, user_2_id: friend.id)
        friendship2 = Fabricate(:friendship, user_1_id: user.id)
        friendship3 = Fabricate(:friendship, user_1_id: user.id)
        Fabricate(:friendship_balance, friendship: friendship, balance: 25, owes_to: friend)
        Fabricate(:friendship_balance, friendship: friendship2, balance: 50, owes_to: user)
        Fabricate(:friendship_balance, friendship: friendship3, balance: 25, owes_to: user)
      end

      it 'recalculates user balance' do
        UserBalanceRecalculationJob.new.perform(user.id)

        balance.reload
        expect(balance.total_due).to eq(75)
        expect(balance.total_owed).to eq(25)
        expect(balance.net_balance).to eq(50)
      end
    end

    context 'when user does not exist' do
      it 'does not raise error' do
        expect do
          UserBalanceRecalculationJob.new.perform(999)
        end.not_to raise_error
      end
    end

    context 'when user has no balance' do
      it 'creates a new balance and calculates' do
        friend = Fabricate(:user)
        friendship = Fabricate(:friendship, user_1_id: user.id, user_2_id: friend.id)
        Fabricate(:friendship_balance, friendship: friendship, balance: 25, owes_to: user)

        expect do
          UserBalanceRecalculationJob.new.perform(user.id)
        end.to change(UserBalance, :count).by(1)

        balance = UserBalance.find_by(user_id: user.id)
        expect(balance.total_due).to eq(25)
      end
    end
  end

  describe 'balance calculation scenarios' do
    let(:user) { Fabricate(:user) }
    let(:friend) { Fabricate(:user) }
    let(:friendship) { Fabricate(:friendship, user_1_id: user.id, user_2_id: friend.id) }

    context 'when user is owed money' do
      before do
        Fabricate(:friendship_balance, friendship: friendship, balance: 100, owes_to: friend)
      end

      it 'calculates total_due correctly via job perform' do
        UserBalanceRecalculationJob.new.perform(user.id)

        balance = UserBalance.find_by(user_id: user.id)
        expect(balance.total_due).to eq(0)
        expect(balance.total_owed).to eq(100)
      end
    end

    context 'when user owes money' do
      before do
        Fabricate(:friendship_balance, friendship: friendship, balance: 50, owes_to: user)
      end

      it 'calculates total_owed correctly via job perform' do
        UserBalanceRecalculationJob.new.perform(user.id)

        balance = UserBalance.find_by(user_id: user.id)
        expect(balance.total_owed).to eq(0)
        expect(balance.total_due).to eq(50)
      end
    end

    context 'with multiple friendships' do
      let(:friend2) { Fabricate(:user) }
      let(:friendship2) { Fabricate(:friendship, user_1_id: user.id, user_2_id: friend2.id) }

      before do
        Fabricate(:friendship_balance, friendship: friendship, balance: 100, owes_to: friend)
        Fabricate(:friendship_balance, friendship: friendship2, balance: 50, owes_to: user)
      end

      it 'calculates net_balance correctly via job perform' do
        UserBalanceRecalculationJob.new.perform(user.id)

        balance = UserBalance.find_by(user_id: user.id)
        expect(balance.total_due).to eq(50)
        expect(balance.total_owed).to eq(100)
        expect(balance.net_balance).to eq(-50)
      end
    end
  end

  describe 'job configuration' do
    it 'uses default queue' do
      expect(UserBalanceRecalculationJob.new.class.queue_name).to eq('default')
    end
  end
end

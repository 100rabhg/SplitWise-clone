# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBalance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    let(:user) { Fabricate(:user) }
    let(:user_balance) { Fabricate.build(:user_balance, user: user) }

    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:total_due) }
    it { is_expected.to validate_presence_of(:total_owed) }
    it { is_expected.to validate_presence_of(:net_balance) }
    it { is_expected.to validate_numericality_of(:total_due) }
    it { is_expected.to validate_numericality_of(:total_owed) }
    it { is_expected.to validate_numericality_of(:net_balance) }

    it 'validates user_id is unique' do
      Fabricate(:user_balance, user: user)
      duplicate_balance = Fabricate.build(:user_balance, user: user)
      expect(duplicate_balance).not_to be_valid
    end
  end
end

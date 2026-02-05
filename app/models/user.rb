# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :name, presence: true
  validates :mobile_number, allow_blank: true, format: { with: /\A[\d\s\-\+\(\)]+\z/, message: 'is invalid' }

  # Associations
  has_one :user_balance, dependent: :destroy

  has_many :friendships, class_name: 'FlatFriendship', foreign_key: :user_id

  has_many :payment_transactions, -> { where(deleted_at: nil) }, through: :friendships
  has_many :friendship_balances, -> { where(deleted_at: nil) }, through: :friendships
  has_many :item_splits, -> { where(deleted_at: nil) }, through: :friendships
  has_many :friends, through: :friendships, source: :friend

  after_create :initialize_user_balance

  # Get or create user balance
  def ensure_balance
    user_balance || create_user_balance
  end

  private

  # Initialize user balance on user creation
  def initialize_user_balance
    UserBalanceRecalculationJob.perform_later(id)
  end
end

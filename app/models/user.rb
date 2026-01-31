# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :friendships, ->(user) { where('user_1_id = :id OR user_2_id = :id', id: user.id) }

  has_many :expense_transactions
  has_many :payment_transactions, through: :friendships
  has_many :friendship_balances, through: :friendships
  has_many :item_splits, through: :friendships

  def friends
    User.joins(:friendships)
        .where('friendships.user_1_id = :id OR friendships.user_2_id = :id', id: id)
        .where.not(id: id)
  end
end

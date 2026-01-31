class FriendshipBalance < ApplicationRecord
  acts_as_paranoid

  belongs_to :friendship
  belongs_to :owes_to, class_name: 'User'

  validates :balance, presence: true, numericality: true
  validates :owes_to_id, presence: true, uniqueness: { scope: :friendship_id }
end

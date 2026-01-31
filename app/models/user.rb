class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :friendships, ->(user) { where("user_1_id = :id OR user_2_id = :id", id: user.id) }, class_name: 'Friendship'
  
  def friends
    User.joins(:friendships)
        .where("friendships.user_1_id = :id OR friendships.user_2_id = :id", id: self.id)
        .where.not(id: self.id)
  end
end

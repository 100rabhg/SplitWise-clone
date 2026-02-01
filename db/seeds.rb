# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def self.random_unconnected_pair
  sql = <<~SQL
    SELECT u1.id AS user_1_id, u2.id AS user_2_id
    FROM users u1
    JOIN users u2 ON u1.id < u2.id
    WHERE NOT EXISTS (
      SELECT 1 FROM flat_friendships
      WHERE user_id = u1.id AND friend_id = u2.id
    )
    ORDER BY RANDOM()
    LIMIT 1
  SQL

  result = ActiveRecord::Base.connection.exec_query(sql).first
  return [result["user_1_id"], result["user_2_id"]] if result

  raise "Not enough unconnected user pairs available."
end


ActiveRecord::Base.transaction do
  10.times do |i|
    User.find_or_create_by!(email: "user#{i + 1}@example.com") do |user|
      user.password = "password123"
      user.name = Faker::Name.name
      user.mobile_number = "#{[6,7,8,9].sample}#{Faker::Number.number(digits: 9)}"
    end
  end

  20.times do
    users = random_unconnected_pair
    Friendship.create!(user_1_id: users.first, user_2_id: users.second)
  end

  # Find the two users with the most friendships
  @top_users = User.joins(:friendships).group(:id).order('COUNT(flat_friendships.id) DESC').limit(2)

  user1 = @top_users.first
  user2 = @top_users.second

  friendships_user1 = user1.friendships.limit(2)
  friendships_user2 = user2.friendships.limit(2)

  # Transaction 1: Dinner expense with nested items and splits
  if friendships_user1.length > 0
    friendship1 = friendships_user1.first
    other_user1_id = friendship1.friend_id

    ExpenseTransaction.create!(
      paid_by_id: user1.id,
      amount: 150,
      notes: "Dinner at #{Faker::Restaurant.name}",
      expense_items_attributes: [
        {
          type: "Item",
          name: Faker::Food.dish,
          amount: 100,
          item_splits_attributes: [
            { user_id: other_user1_id, friendship_id: friendship1.id, amount: 100 }
          ]
        },
        {
          type: "Item",
          name: Faker::Food.dish,
          amount: 50,
          item_splits_attributes: [
            { user_id: user1.id, friendship_id: friendship1.id, amount: 50 }
          ]
        }
      ]
    )
  end

  # Transaction 2: Movie and snacks
  if friendships_user1.length > 1
    friendship2 = friendships_user1.second
    other_user2_id = friendship2.friend_id

    ExpenseTransaction.create!(
      paid_by_id: user1.id,
      amount: 80,
      notes: "Movie outing",
      expense_items_attributes: [
        {
          type: "Item",
          name: "Movie Tickets",
          amount: 50,
          item_splits_attributes: [
            { user_id: other_user2_id, friendship_id: friendship2.id, amount: 25 },
            { user_id: user1.id, friendship_id: friendship2.id, amount: 25 }
          ]
        },
        {
          type: "Item",
          name: "Snacks & Drinks",
          amount: 30,
          item_splits_attributes: [
            { user_id: other_user2_id, friendship_id: friendship2.id, amount: 30 }
          ]
        }
      ]
    )
  end

  # Transaction 3: Weekend trip groceries
  if friendships_user2.length > 0
    friendship3 = friendships_user2.first
    other_user3_id = friendship3.friend_id

    ExpenseTransaction.create!(
      paid_by_id: user2.id,
      amount: 200,
      notes: "Weekend trip groceries",
      expense_items_attributes: [
        {
          type: "Item",
          name: "Groceries",
          amount: 120,
          item_splits_attributes: [
            { user_id: other_user3_id, friendship_id: friendship3.id, amount: 60 },
            { user_id: user2.id, friendship_id: friendship3.id, amount: 60 }
          ]
        },
        {
          type: "Item",
          name: "Gas",
          amount: 80,
          item_splits_attributes: [
            { user_id: other_user3_id, friendship_id: friendship3.id, amount: 40 },
            { user_id: user2.id, friendship_id: friendship3.id, amount: 40 }
          ]
        }
      ]
    )
  end
end

puts "✅ Database seeded successfully!"
puts "📧 Users created: user1@example.com through user10@example.com"
puts "🔑 Password: password123"
puts "\n📊 Top 2 Users with Most Friendships: #{@top_users.first.email}, #{@top_users.second.email}"

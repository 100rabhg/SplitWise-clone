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

  20.times do |i|
    users = random_unconnected_pair
    Friendship.create(user_1_id: users.first, user_2_id: users.second)
  end
end

puts "✅ 10 users created"
puts "📧 Email: user1@example.com ... user10@example.com"
puts "🔑 Password: password123"

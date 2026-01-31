# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


10.times do |i|
  Fabricate(
    :user,
    email: "user#{i + 1}@example.com",
    password: "password123"
  )
end

puts "✅ 10 users created"
puts "📧 Email: user1@example.com ... user10@example.com"
puts "🔑 Password: password123"
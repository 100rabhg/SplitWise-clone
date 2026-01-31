Fabricator(:user) do
  name          { Faker::Name.name }
  email         { sequence(:email) { |i| "user#{i}@example.com" } }
  mobile_number { Faker::PhoneNumber.phone_number }
  password      { 'password123' }
end

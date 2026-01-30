Fabricator(:user) do
  name              { Faker::Name.name }  
  email             { Faker::Internet.email }
  mobile_number     { Faker::PhoneNumber.phone_number }
  password          { Faker::Alphanumeric.alpha(number: 10) }
end
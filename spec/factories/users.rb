FactoryBot.define do
  factory :user do
    name { 'John Doe' }
    sequence(:email) { |n| "john.doe#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    association :role
  end
end

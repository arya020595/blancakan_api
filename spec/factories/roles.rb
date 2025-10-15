FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "Can manage their own events." }
  end
end

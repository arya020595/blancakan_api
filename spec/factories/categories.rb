FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Sample Category #{n}" }
    description { 'Sample Description' }
  end
end

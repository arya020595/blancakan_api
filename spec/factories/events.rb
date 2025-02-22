FactoryBot.define do
  factory :event do
    title { 'Sample Event' }
    description { 'This is a sample event description.' }
    starts_at { '2025-02-22 10:00:00' }
    ends_at { '2025-03-22 18:00:00' }
    location { 'Sample Location' }
    organizer { 'Sample Organizer' }
    status { 'draft' }
    association :category
    association :user
  end
end

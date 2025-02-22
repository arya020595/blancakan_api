FactoryBot.define do
  factory :permission do
    action { 'read' }
    subject_class { %w[User Permission] }
    conditions { {} }
    association :role
  end
end

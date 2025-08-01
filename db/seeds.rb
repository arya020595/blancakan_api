# To run all seeds, execute:
# rails db:seed

# Load seed files
load Rails.root.join('db/seeds/roles_and_permissions.rb')
load Rails.root.join('db/seeds/users.rb')
load Rails.root.join('db/seeds/organizers.rb')
load Rails.root.join('db/seeds/categories.rb')
load Rails.root.join('db/seeds/payment_methods.rb')

load Rails.root.join('db/seeds/event_types.rb')
load Rails.root.join('db/seeds/events.rb')
load Rails.root.join('db/seeds/ticket_types.rb')

puts 'Seeding process completed!'

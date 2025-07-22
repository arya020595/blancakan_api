# Load seed files
load Rails.root.join('db/seeds/roles_and_permissions.rb')
load Rails.root.join('db/seeds/users.rb')
load Rails.root.join('db/seeds/organizers.rb')
load Rails.root.join('db/seeds/categories.rb')
load Rails.root.join('db/seeds/event_types.rb')
load Rails.root.join('db/seeds/events.rb')

puts 'Seeding process completed!'

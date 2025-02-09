# Clear existing data
Role.destroy_all
Permission.destroy_all

# Create Roles
Role.create!(name: 'superadmin')
Role.create!(name: 'admin')
Role.create!(name: 'organizer')
Role.create!(name: 'premium_organizer')

# Define Permissions
# read: [:index, :show]
# create: [:new, :create]
# update: [:edit, :update]
# destroy: [:destroy]

permissions = %w[
  read_events create_events update_events delete_events
]

permissions.each { |perm| Permission.create!(name: perm) }

puts 'Roles and permissions seeding completed successfully!'

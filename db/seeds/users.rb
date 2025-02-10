# Clear existing users
User.destroy_all

# Fetch roles
superadmin_role = Role.find_by(name: 'superadmin')
admin_role = Role.find_by(name: 'admin')
organizer_role = Role.find_by(name: 'organizer')
premium_organizer_role = Role.find_by(name: 'premium_organizer')

# Create Users with assigned roles
User.create!(
  email: 'superadmin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: superadmin_role
)

User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: admin_role
)

User.create!(
  email: 'organizer@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: organizer_role
)

User.create!(
  email: 'premium_organizer@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: premium_organizer_role
)

puts 'Users seeding completed successfully!'

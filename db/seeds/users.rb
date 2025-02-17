# Clear existing users
User.destroy_all

# Fetch roles
superadmin_role = Role.find_by(name: 'superadmin')
admin_role = Role.find_by(name: 'admin')
organizer_role = Role.find_by(name: 'organizer')
premium_organizer_role = Role.find_by(name: 'premium_organizer')

# Create Users with assigned roles
User.create!(
  name: 'Super Admin',
  email: 'superadmin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: superadmin_role
)

User.create!(
  name: 'Admin User',
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: admin_role
)

User.create!(
  name: 'Organizer One',
  email: 'organizer@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: organizer_role
)

User.create!(
  name: 'Premium Organizer',
  email: 'premium_organizer@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: premium_organizer_role
)

# Add another organizer
User.create!(
  name: 'Organizer Two',
  email: 'organizer2@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: organizer_role
)

puts 'Users seeding completed successfully!'

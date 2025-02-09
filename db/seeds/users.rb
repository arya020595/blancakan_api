# Clear existing users
User.destroy_all

# Create Users
superadmin_user = User.create!(
  email: 'superadmin@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
superadmin_user.add_role(:superadmin)

admin_user = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
admin_user.add_role(:admin)
admin_user.permissions << Permission.where(name: %w[read_events create_events update_events delete_events])

organizer_user = User.create!(
  email: 'organizer@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
organizer_user.add_role(:organizer)
organizer_user.permissions << Permission.where(name: %w[read_events create_events update_events delete_events])

premium_organizer_user = User.create!(
  email: 'premium_organizer@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
premium_organizer_user.add_role(:premium_organizer)
premium_organizer_user.permissions << Permission.where(name: %w[
                                                         read_events create_events update_events delete_events
                                                       ])

puts 'User seeding completed successfully!'

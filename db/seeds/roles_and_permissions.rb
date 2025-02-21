# Clear existing data
Role.destroy_all
Permission.destroy_all

# Create Roles
roles = {
  'superadmin' => {
    description: 'Has full access to all resources and actions.',
    permissions: []
  },
  'admin' => {
    description: 'Can manage users and read events.',
    permissions: [
      { action: 'read', subject_class: 'User' },
      { action: 'manage', subject_class: 'User' },
      { action: 'read', subject_class: 'Event' }
    ]
  },
  'organizer' => {
    description: 'Can manage their own events.',
    permissions: [
      { action: 'read', subject_class: 'Event' },
      { action: 'create', subject_class: 'Event' },
      { action: 'update', subject_class: 'Event', conditions: { user_id: 'user.id' } },
      { action: 'destroy', subject_class: 'Event', conditions: { user_id: 'user.id' } }
    ]
  },
  'premium_organizer' => {
    description: 'Can manage their own events and create tickets.',
    permissions: [
      { action: 'read', subject_class: 'Event' },
      { action: 'create', subject_class: 'Event' },
      { action: 'update', subject_class: 'Event', conditions: { user_id: 'user.id' } },
      { action: 'destroy', subject_class: 'Event', conditions: { user_id: 'user.id' } },
      { action: 'create', subject_class: 'Ticket' }
    ]
  }
}

# Create roles and assign permissions
roles.each do |role_name, role_data|
  role = Role.create!(name: role_name, description: role_data[:description])

  role_data[:permissions].each do |perm|
    role.permissions.create!(
      action: perm[:action],
      subject_class: perm[:subject_class],
      conditions: perm[:conditions] || {}
    )
  end
end

puts 'Roles and permissions seeding completed successfully!'

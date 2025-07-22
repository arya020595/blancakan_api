# frozen_string_literal: true

# Seed file for Organizer model
# Creates sample organizer profiles for testing and development

puts '🌱 Seeding Organizer data...'

# Get some existing users to create organizer profiles for
users = User.limit(5)

if users.empty?
  puts '❌ No users found. Please seed users first.'
  return
end

sample_organizers = [
  {
    handle: '@blancakan_id',
    name: 'Blancakan ID',
    description: 'Organizing curated creative events across Jakarta. Bringing together artists, designers, and creative minds.',
    contact_phone: '+6281234567890'
    # NOTE: avatar can be uploaded later via API
  },
  {
    handle: '@techjakarta',
    name: 'Tech Jakarta',
    description: 'Premier technology events in Jakarta. Conferences, workshops, and networking for developers.',
    contact_phone: '+6281234567891'
  },
  {
    handle: '@artspace_jkt',
    name: 'ArtSpace Jakarta',
    description: 'Contemporary art exhibitions and cultural events. Showcasing local and international artists.',
    contact_phone: '+6281234567892'
  },
  {
    handle: '@foodie_events',
    name: 'Foodie Events',
    description: 'Culinary experiences and food festivals. Taste the best of Indonesian and international cuisine.',
    contact_phone: '+6281234567893'
  },
  {
    handle: '@wellness_hub',
    name: 'Wellness Hub',
    description: 'Health and wellness workshops, yoga retreats, and mindfulness sessions for urban professionals.',
    contact_phone: '+6281234567894'
  }
]

created_count = 0

sample_organizers.each_with_index do |organizer_data, index|
  user = users[index]
  next unless user

  # Skip if user already has an organizer profile
  if user.organizer.present?
    puts "⏭️  User #{user.email} already has an organizer profile"
    next
  end

  begin
    organizer = user.build_organizer(organizer_data)

    if organizer.save
      created_count += 1
      puts "✅ Created organizer: #{organizer.handle} (#{organizer.name})"
    else
      puts "❌ Failed to create organizer for #{user.email}: #{organizer.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    puts "❌ Failed to create organizer for #{user.email}: #{e.message}"
  end
end

puts "\n📊 Organizer seeding completed!"
puts "   Created: #{created_count} organizers"
puts "   Total organizers: #{Organizer.count}"

# Display summary
if Organizer.count > 0
  puts "\n📋 Current organizers:"
  Organizer.each do |organizer|
    status = organizer.is_active ? '🟢' : '🔴'
    puts "   #{status} #{organizer.handle} - #{organizer.name} (#{organizer.user.email})"
  end
end

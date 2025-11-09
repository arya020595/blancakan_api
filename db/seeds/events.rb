# Clear existing events
Event.destroy_all

# Fetch all categories and assign randomly
categories = Category.all.to_a
raise 'No categories found! Run the categories seed file first.' if categories.empty?

# Fetch all organizers and assign randomly
organizers = Organizer.all.to_a
raise 'No organizers found! Run the organizers seed file first.' if organizers.empty?

# Fetch all event types
event_types = EventType.all.to_a
raise 'No event types found! Run the event_types seed file first.' if event_types.empty?

# Common timezones for random assignment
timezones = [
  'America/Los_Angeles', 'America/New_York', 'America/Chicago', 'America/Denver',
  'Europe/London', 'Europe/Paris', 'Europe/Berlin', 'Asia/Tokyo', 'Asia/Singapore',
  'Asia/Dubai', 'Australia/Sydney', 'Pacific/Auckland', 'Asia/Jakarta'
]

# Location types
location_types = %w[offline online hybrid]

# Cities with states/countries for location
cities = [
  { city: 'San Francisco', state: 'CA', country: 'USA' },
  { city: 'New York', state: 'NY', country: 'USA' },
  { city: 'Austin', state: 'TX', country: 'USA' },
  { city: 'Seattle', state: 'WA', country: 'USA' },
  { city: 'Boston', state: 'MA', country: 'USA' },
  { city: 'London', state: '', country: 'UK' },
  { city: 'Berlin', state: '', country: 'Germany' },
  { city: 'Paris', state: '', country: 'France' },
  { city: 'Tokyo', state: '', country: 'Japan' },
  { city: 'Sydney', state: 'NSW', country: 'Australia' },
  { city: 'Singapore', state: '', country: 'Singapore' },
  { city: 'Toronto', state: 'ON', country: 'Canada' },
  { city: 'Amsterdam', state: '', country: 'Netherlands' },
  { city: 'Barcelona', state: '', country: 'Spain' },
  { city: 'Dubai', state: '', country: 'UAE' }
]

puts 'Generating 100 diverse events with Faker...'

# Generate events
100.times do |i|
  # Select random categories (1-3)
  selected_categories = categories.sample(rand(1..3))

  # Pick location type
  location_type = location_types.sample

  # Generate location data
  location = if location_type == 'online'
               { platform: ['Zoom', 'Google Meet', 'Microsoft Teams', 'Webex', 'Custom Platform'].sample }
             else
               city_data = cities.sample
               {
                 city: city_data[:city],
                 state: city_data[:state],
                 country: city_data[:country],
                 address: "#{rand(100..9999)} #{['Main St', 'Broadway', 'Park Ave', 'First St', 'Market St', 'Tech Blvd',
                                                 'Innovation Way'].sample}"
               }
             end

  # Random event type
  event_type = event_types.sample

  # Random timezone
  timezone = timezones.sample

  # Random start date between now and 6 months from now
  start_offset_days = rand(7..180)
  start_hour = rand(8..19)

  # Duration between 1 hour and 3 days
  duration_hours = [1, 2, 3, 4, 6, 8, 12, 24, 36, 48, 72].sample

  # Generate title and description using Faker
  base_title = Faker::Company.catch_phrase
  base_description = Faker::Lorem.paragraph(sentence_count: rand(3..7),
                                            supplemental: true,
                                            random_sentences_to_add: rand(2..5))

  # Calculate start and end times
  start_time = (Time.current + start_offset_days.days).change(hour: start_hour, min: [0, 15, 30, 45].sample)
  end_time = start_time + duration_hours.hours

  # Create event attributes
  event_attrs = {
    title: "#{base_title} #{event_type.name}",
    description: base_description,
    location_type: location_type,
    location: location,
    starts_at_local: start_time,
    ends_at_local: end_time,
    timezone: timezone,
    is_paid: rand < 0.6, # 60% chance of being paid
    organizer: organizers.sample,
    event_type: event_type,
    categories: selected_categories,
    status: %w[draft published published published].sample # 75% published
  }

  # Special overrides for more realistic titles based on event type
  case event_type.name
  when 'Conference'
    event_attrs[:title] =
      "#{Faker::Company.industry} #{%w[Annual Global International Leaders
                                       Innovation].sample} Conference #{rand(2023..2026)}"
  when 'Workshop'
    event_attrs[:title] =
      "#{%w[Hands-on Practical Interactive Immersive Intensive].sample} #{Faker::Company.bs.titleize} Workshop"
  when 'Festival'
    event_attrs[:title] =
      "#{Faker::Address.city} #{%w[Summer Winter Spring Fall
                                   Annual].sample} #{%w[Arts Music Food Film Cultural].sample} Festival"
  when 'Competition'
    event_attrs[:title] =
      "#{%w[National International Regional Global
            Championship].sample} #{Faker::Game.title} #{%w[Tournament Competition Challenge Championship].sample}"
  when 'Seminar'
    event_attrs[:title] =
      "#{%w[Advanced Essential Modern Strategic Practical].sample} #{Faker::Company.bs.titleize} Seminar"
  end

  # Make online events have online-specific titles and descriptions
  if %w[online hybrid].include?(location_type)
    event_attrs[:title] = "Virtual #{event_attrs[:title]}" if rand > 0.5
    event_attrs[:description] = "Join us online for this #{event_type.name.downcase}! " + event_attrs[:description]
  end

  # Create the event
  event = Event.create!(event_attrs)
  puts "✓ Created Event #{i + 1}/100: #{event.title}"
end

puts "Events seeding completed successfully! Created #{Event.count} events."

# Clear existing events
Event.destroy_all


# Fetch all categories and assign randomly
categories = Category.all.to_a

# Fetch all organizers and assign randomly
organizers = Organizer.all.to_a

# Create Events
# Note: location is now a Hash, organizer is a reference, categories is HABTM
# Use start_date, start_time, end_date, end_time, and other new fields

events = [
  {
    title: 'Tech Conference 2025',
    description: 'A conference about the latest in technology.',
    location_type: 'offline',
    location: { city: 'San Francisco', state: 'CA', address: '123 Tech St.' },
    start_date: (Time.current + 1.month).to_date,
    start_time: (Time.current + 1.month).change(hour: 9, min: 0),
    end_date: (Time.current + 1.month + 1.day).to_date,
    end_time: (Time.current + 1.month + 1.day).change(hour: 17, min: 0),
    timezone: 'America/Los_Angeles',
    is_paid: false,
    organizer: organizers.sample,
    event_type: EventType.first,
    categories: [categories.sample]
  },
  {
    title: 'Ruby Workshop',
    description: 'A workshop to learn Ruby programming.',
    location_type: 'offline',
    location: { city: 'New York', state: 'NY', address: '456 Ruby Ave.' },
    start_date: (Time.current + 2.months).to_date,
    start_time: (Time.current + 2.months).change(hour: 10, min: 0),
    end_date: (Time.current + 2.months + 1.day).to_date,
    end_time: (Time.current + 2.months + 1.day).change(hour: 16, min: 0),
    timezone: 'America/New_York',
    is_paid: true,
    organizer: organizers.sample,
    event_type: EventType.first,
    categories: [categories.sample]
  },
  {
    title: 'Startup Meetup',
    description: 'A meetup for startup enthusiasts.',
    location_type: 'offline',
    location: { city: 'Los Angeles', state: 'CA', address: '789 Startup Blvd.' },
    start_date: (Time.current + 3.months).to_date,
    start_time: (Time.current + 3.months).change(hour: 18, min: 0),
    end_date: (Time.current + 3.months + 1.day).to_date,
    end_time: (Time.current + 3.months + 1.day).change(hour: 21, min: 0),
    timezone: 'America/Los_Angeles',
    is_paid: false,
    organizer: organizers.sample,
    event_type: EventType.first,
    categories: [categories.sample]
  }
]

events.each do |event_attrs|
  Event.create!(event_attrs)
end

puts 'Events seeding completed successfully!'
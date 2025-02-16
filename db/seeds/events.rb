# Clear existing events
Event.destroy_all

# Fetch created categories
conference_category = Category.find_by(name: 'Conference')
workshop_category = Category.find_by(name: 'Workshop')
meetup_category = Category.find_by(name: 'Meetup')

# Create Events
events = [
  {
    title: 'Tech Conference 2025',
    description: 'A conference about the latest in technology.',
    location: 'San Francisco, CA',
    starts_at: Time.current + 1.month,
    ends_at: Time.current + 1.month + 1.day,
    category: conference_category
  },
  {
    title: 'Ruby Workshop',
    description: 'A workshop to learn Ruby programming.',
    location: 'New York, NY',
    starts_at: Time.current + 2.months,
    ends_at: Time.current + 2.months + 1.day,
    category: workshop_category
  },
  {
    title: 'Startup Meetup',
    description: 'A meetup for startup enthusiasts.',
    location: 'Los Angeles, CA',
    starts_at: Time.current + 3.months,
    ends_at: Time.current + 3.months + 1.day,
    category: meetup_category
  }
]

events.each do |event|
  Event.create!(event)
end

puts 'Events seeding completed successfully!'

# frozen_string_literal: true

puts 'Creating EventTypes...'

event_types = [
  {
    name: 'Workshop',
    slug: 'workshop',
    icon_url: 'https://cdn.example.com/icons/workshop.png',
    description: 'Hands-on learning sessions with practical activities',
    is_active: true,
    sort_order: 1
  },
  {
    name: 'Seminar',
    slug: 'seminar',
    icon_url: 'https://cdn.example.com/icons/seminar.png',
    description: 'Educational presentations and discussions',
    is_active: true,
    sort_order: 2
  },
  {
    name: 'Conference',
    slug: 'conference',
    icon_url: 'https://cdn.example.com/icons/conference.png',
    description: 'Large-scale professional gatherings',
    is_active: true,
    sort_order: 3
  },
  {
    name: 'Networking',
    slug: 'networking',
    icon_url: 'https://cdn.example.com/icons/networking.png',
    description: 'Professional networking and social events',
    is_active: true,
    sort_order: 4
  },
  {
    name: 'Webinar',
    slug: 'webinar',
    icon_url: 'https://cdn.example.com/icons/webinar.png',
    description: 'Online presentations and virtual events',
    is_active: true,
    sort_order: 5
  }
]

event_types.each do |event_type_data|
  event_type = EventType.find_or_create_by(slug: event_type_data[:slug]) do |et|
    et.name = event_type_data[:name]
    et.icon_url = event_type_data[:icon_url]
    et.description = event_type_data[:description]
    et.is_active = event_type_data[:is_active]
    et.sort_order = event_type_data[:sort_order]
  end

  if event_type.persisted?
    puts "✓ Created EventType: #{event_type.name}"
  else
    puts "✗ Failed to create EventType: #{event_type_data[:name]} - #{event_type.errors.full_messages.join(', ')}"
  end
end

puts 'EventTypes creation completed!'
puts "Total EventTypes: #{EventType.count}"

# frozen_string_literal: true

puts 'Creating EventTypes...'

event_types = [
  {
    name: 'Conference',
    slug: 'conference',
    icon_url: 'https://cdn.example.com/icons/conference.png',
    description: 'Large-scale professional gatherings with multiple speakers and sessions',
    is_active: true,
    sort_order: 1
  },
  {
    name: 'Workshop',
    slug: 'workshop',
    icon_url: 'https://cdn.example.com/icons/workshop.png',
    description: 'Hands-on learning sessions with practical activities',
    is_active: true,
    sort_order: 2
  },
  {
    name: 'Festival',
    slug: 'festival',
    icon_url: 'https://cdn.example.com/icons/festival.png',
    description: 'Celebrations featuring music, arts, culture, food or other themes',
    is_active: true,
    sort_order: 3
  },
  {
    name: 'Competition',
    slug: 'competition',
    icon_url: 'https://cdn.example.com/icons/competition.png',
    description: 'Contests where participants compete for prizes or recognition',
    is_active: true,
    sort_order: 4
  },
  {
    name: 'Seminar',
    slug: 'seminar',
    icon_url: 'https://cdn.example.com/icons/seminar.png',
    description: 'Educational presentations and discussions on specific topics',
    is_active: true,
    sort_order: 5
  },
  {
    name: 'Exhibition',
    slug: 'exhibition',
    icon_url: 'https://cdn.example.com/icons/exhibition.png',
    description: 'Public displays of art, products, or information',
    is_active: true,
    sort_order: 6
  },
  {
    name: 'Retreat',
    slug: 'retreat',
    icon_url: 'https://cdn.example.com/icons/retreat.png',
    description: 'Immersive getaways focused on specific activities or wellness',
    is_active: true,
    sort_order: 7
  },
  {
    name: 'Summit',
    slug: 'summit',
    icon_url: 'https://cdn.example.com/icons/summit.png',
    description: 'High-level gatherings focused on thought leadership and industry trends',
    is_active: true,
    sort_order: 8
  },
  {
    name: 'Webinar',
    slug: 'webinar',
    icon_url: 'https://cdn.example.com/icons/webinar.png',
    description: 'Online presentations and virtual events',
    is_active: true,
    sort_order: 9
  },
  {
    name: 'Networking',
    slug: 'networking',
    icon_url: 'https://cdn.example.com/icons/networking.png',
    description: 'Professional networking and social events',
    is_active: true,
    sort_order: 10
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

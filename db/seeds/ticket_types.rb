# frozen_string_literal: true

# Clear existing data
puts 'Cleaning TicketTypes...'
TicketType.destroy_all

# Seed data for TicketType
puts 'Seeding TicketTypes...'

Event.all.each do |event|
  [
    {
      name: 'VIP Day 1', description: 'Access to VIP lounge', price: 250_000, quota: 200,
      available_from: DateTime.parse('2025-07-01T00:00:00Z'), available_until: DateTime.parse('2025-07-20T23:59:59Z'),
      valid_on: DateTime.parse('2025-07-21T00:00:00Z'), is_active: true, sort_order: 1, metadata: '{ tier: "premium" }'
    },
    {
      name: 'General Admission Day 1', description: 'Standard entry', price: 100_000, quota: 500,
      available_from: DateTime.parse('2025-07-01T00:00:00Z'), available_until: DateTime.parse('2025-07-20T23:59:59Z'),
      valid_on: DateTime.parse('2025-07-21T00:00:00Z'), is_active: true, sort_order: 2, metadata: '{ tier: "standard" }'
    },
    {
      name: 'VIP Day 2', description: 'Access to VIP lounge', price: 250_000, quota: 200,
      available_from: DateTime.parse('2025-07-01T00:00:00Z'), available_until: DateTime.parse('2025-07-20T23:59:59Z'),
      valid_on: DateTime.parse('2025-07-22T00:00:00Z'), is_active: true, sort_order: 3, metadata: '{ tier: "premium" }'
    },
    {
      name: 'General Admission Day 2', description: 'Standard entry', price: 100_000, quota: 500,
      available_from: DateTime.parse('2025-07-01T00:00:00Z'), available_until: DateTime.parse('2025-07-20T23:59:59Z'),
      valid_on: DateTime.parse('2025-07-22T00:00:00Z'), is_active: true, sort_order: 4, metadata: '{ tier: "standard" }'
    }
  ].each do |attrs|
    event.ticket_types.find_or_create_by!(attrs)
  end
end

puts 'TicketTypes seeding complete.'

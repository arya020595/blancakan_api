# Clear existing categories
Category.destroy_all

# Create Categories
categories = [
  { name: 'Conference', description: 'Events related to conferences', is_active: true },
  { name: 'Workshop', description: 'Events related to workshops', is_active: true },
  { name: 'Meetup', description: 'Events related to meetups', is_active: true }
]

categories.each do |category|
  Category.create!(category)
end

puts 'Categories seeding completed successfully!'

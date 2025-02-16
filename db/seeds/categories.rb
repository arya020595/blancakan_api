# Clear existing categories
Category.destroy_all

# Create Categories
categories = [
  { name: 'Conference', description: 'Events related to conferences', status: true },
  { name: 'Workshop', description: 'Events related to workshops', status: true },
  { name: 'Meetup', description: 'Events related to meetups', status: true }
]

categories.each do |category|
  Category.create!(category)
end

puts 'Categories seeding completed successfully!'

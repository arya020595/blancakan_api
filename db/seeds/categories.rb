# Clear existing categories
Category.destroy_all

# Create Categories (Themes)
categories = [
  { name: 'Business', description: 'Events related to entrepreneurship, startups, and corporate networking', is_active: true },
  { name: 'Social', description: 'Events focused on social interactions and community building', is_active: true },
  { name: 'Personal Development', description: 'Events for self-improvement and growth', is_active: true },
  { name: 'Charity', description: 'Fundraising and nonprofit events for good causes', is_active: true },
  { name: 'Sports', description: 'Athletic competitions, tournaments and fitness events', is_active: true },
  { name: 'Educational', description: 'Learning-focused events and academic gatherings', is_active: true },
  { name: 'Technology', description: 'Events featuring the latest in tech innovation', is_active: true },
  { name: 'Arts & Culture', description: 'Events celebrating creative expression and cultural heritage', is_active: true },
  { name: 'Health & Wellness', description: 'Events promoting physical and mental wellbeing', is_active: true },
  { name: 'Entertainment', description: 'Fun and recreational events for enjoyment', is_active: true },
  { name: 'Food & Drink', description: 'Culinary experiences and beverage tastings', is_active: true },
  { name: 'Science', description: 'Events focused on scientific discovery and research', is_active: true }
]

categories.each do |category|
  Category.create!(category)
end

puts "Categories seeding completed successfully! Created #{Category.count} categories."

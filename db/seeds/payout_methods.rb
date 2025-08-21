# frozen_string_literal: true

# PayoutMethod Seeds
puts 'Seeding PayoutMethods...'

# Ensure we have banks and users first
if Bank.count == 0
  puts 'No banks found. Please seed banks first.'
  exit
end

if User.count == 0
  puts 'No users found. Please seed users first.'
  exit
end

# Get some active banks and users
banks = Bank.active.limit(5)
users = User.limit(10)

# Sample withdrawal rules configurations
withdrawal_rules_configs = [
  { 'min' => 100_000, 'cooldown_hours' => 24 },
  { 'min' => 50_000, 'max' => 10_000_000, 'cooldown_hours' => 12 },
  { 'min' => 200_000, 'cooldown_hours' => 48 },
  { 'min' => 75_000, 'max' => 5_000_000, 'cooldown_hours' => 24 },
  { 'min' => 100_000, 'max' => 20_000_000, 'cooldown_hours' => 72 }
]

# Sample account holders and account numbers
payout_method_data = [
  { account_holder: 'John Doe', account_no: '1234567890' },
  { account_holder: 'Jane Smith', account_no: '9876543210' },
  { account_holder: 'Robert Johnson', account_no: '5555666677' },
  { account_holder: 'Maria Garcia', account_no: '1111222233' },
  { account_holder: 'David Wilson', account_no: '4444555566' },
  { account_holder: 'Sarah Brown', account_no: '7777888899' },
  { account_holder: 'Michael Davis', account_no: '3333444455' },
  { account_holder: 'Lisa Anderson', account_no: '6666777788' },
  { account_holder: 'James Martinez', account_no: '2222333344' },
  { account_holder: 'Jennifer Taylor', account_no: '8888999900' }
]

# Clear existing payout methods
PayoutMethod.delete_all

payout_methods_created = 0

users.each_with_index do |user, index|
  # Each user gets one payout method
  bank = banks.sample
  data = payout_method_data[index % payout_method_data.length]
  rules = withdrawal_rules_configs.sample

  payout_method = PayoutMethod.new(
    user: user,
    bank: bank,
    bank_account_no: data[:account_no],
    account_holder: data[:account_holder],
    withdrawal_rules: rules,
    is_active: true
  )

  # Set a default PIN (in real app, user would set this)
  payout_method.set_pin('123456')

  if payout_method.save
    payout_methods_created += 1
    puts "✓ Created payout method for #{user.email} with bank #{bank.name}"
  else
    puts "✗ Failed to create payout method for #{user.email}: #{payout_method.errors.full_messages.join(', ')}"
  end
rescue StandardError => e
  puts "✗ Error creating payout method for #{user.email}: #{e.message}"
end

puts "\nPayoutMethod seeding completed!"
puts "Created: #{payout_methods_created} payout methods"
puts "Total payout methods in database: #{PayoutMethod.count}"

# Display some statistics
puts "\nPayout Method Statistics:"
puts "Active payout methods: #{PayoutMethod.active.count}"
puts "Inactive payout methods: #{PayoutMethod.inactive.count}"

# Show distribution by bank
puts "\nDistribution by Bank:"
PayoutMethod.collection.aggregate([
                                    {
                                      '$lookup' => {
                                        from: 'banks',
                                        localField: 'bank_id',
                                        foreignField: '_id',
                                        as: 'bank_info'
                                      }
                                    },
                                    {
                                      '$unwind' => '$bank_info'
                                    },
                                    {
                                      '$group' => {
                                        _id: '$bank_info.name',
                                        count: { '$sum' => 1 }
                                      }
                                    },
                                    {
                                      '$sort' => { count: -1 }
                                    }
                                  ]).each do |result|
  puts "#{result['_id']}: #{result['count']} payout methods"
end

# Show withdrawal rules summary
puts "\nWithdrawal Rules Summary:"
min_amounts = PayoutMethod.pluck(:withdrawal_rules).map { |rules| rules.dig('min') }.compact
if min_amounts.any?
  puts "Average minimum withdrawal: Rp #{min_amounts.sum / min_amounts.size}"
  puts "Lowest minimum withdrawal: Rp #{min_amounts.min}"
  puts "Highest minimum withdrawal: Rp #{min_amounts.max}"
end

puts "\nPayoutMethod seeding completed successfully! 🎉"

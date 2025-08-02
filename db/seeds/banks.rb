# frozen_string_literal: true

puts 'Seeding Banks...'

# Clear existing banks
Bank.delete_all

banks = [
  # Major Indonesian Banks
  {
    code: 'BCA',
    name: 'Bank Central Asia',
    logo_url: 'https://cdn.example.com/banks/bca.png',
    is_active: true
  },
  {
    code: 'MANDIRI',
    name: 'Bank Mandiri',
    logo_url: 'https://cdn.example.com/banks/mandiri.png',
    is_active: true
  },
  {
    code: 'BNI',
    name: 'Bank Negara Indonesia',
    logo_url: 'https://cdn.example.com/banks/bni.png',
    is_active: true
  },
  {
    code: 'BRI',
    name: 'Bank Rakyat Indonesia',
    logo_url: 'https://cdn.example.com/banks/bri.png',
    is_active: true
  },
  {
    code: 'CIMB',
    name: 'CIMB Niaga',
    logo_url: 'https://cdn.example.com/banks/cimb.png',
    is_active: true
  },
  {
    code: 'PERMATA',
    name: 'Bank Permata',
    logo_url: 'https://cdn.example.com/banks/permata.png',
    is_active: true
  },
  {
    code: 'DANAMON',
    name: 'Bank Danamon',
    logo_url: 'https://cdn.example.com/banks/danamon.png',
    is_active: true
  },
  {
    code: 'MAYBANK',
    name: 'Maybank Indonesia',
    logo_url: 'https://cdn.example.com/banks/maybank.png',
    is_active: true
  },
  {
    code: 'OCBC',
    name: 'OCBC NISP',
    logo_url: 'https://cdn.example.com/banks/ocbc.png',
    is_active: true
  },
  {
    code: 'PANIN',
    name: 'Bank Panin',
    logo_url: 'https://cdn.example.com/banks/panin.png',
    is_active: true
  },
  {
    code: 'BTPN',
    name: 'Bank BTPN',
    logo_url: 'https://cdn.example.com/banks/btpn.png',
    is_active: true
  },
  {
    code: 'MEGA',
    name: 'Bank Mega',
    logo_url: 'https://cdn.example.com/banks/mega.png',
    is_active: true
  },
  {
    code: 'BUKOPIN',
    name: 'Bank Bukopin',
    logo_url: 'https://cdn.example.com/banks/bukopin.png',
    is_active: true
  },
  {
    code: 'BJB',
    name: 'Bank BJB',
    logo_url: 'https://cdn.example.com/banks/bjb.png',
    is_active: true
  },
  {
    code: 'BSI',
    name: 'Bank Syariah Indonesia',
    logo_url: 'https://cdn.example.com/banks/bsi.png',
    is_active: true
  },

  # Digital Banks
  {
    code: 'JAGO',
    name: 'Bank Jago',
    logo_url: 'https://cdn.example.com/banks/jago.png',
    is_active: true
  },
  {
    code: 'JENIUS',
    name: 'Jenius by BTPN',
    logo_url: 'https://cdn.example.com/banks/jenius.png',
    is_active: true
  },
  {
    code: 'DIGIBANK',
    name: 'Digibank by DBS',
    logo_url: 'https://cdn.example.com/banks/digibank.png',
    is_active: true
  },

  # Regional Banks
  {
    code: 'BANK_DKI',
    name: 'Bank DKI',
    logo_url: 'https://cdn.example.com/banks/dki.png',
    is_active: true
  },
  {
    code: 'BANK_JATENG',
    name: 'Bank Jateng',
    logo_url: 'https://cdn.example.com/banks/jateng.png',
    is_active: true
  },

  # International Banks (might be inactive by default)
  {
    code: 'HSBC',
    name: 'HSBC Indonesia',
    logo_url: 'https://cdn.example.com/banks/hsbc.png',
    is_active: false # Disabled by default, can be enabled if needed
  },
  {
    code: 'CITIBANK',
    name: 'Citibank Indonesia',
    logo_url: 'https://cdn.example.com/banks/citibank.png',
    is_active: false # Disabled by default
  }
]

banks.each do |bank_attrs|
  bank = Bank.find_or_create_by(code: bank_attrs[:code])

  if bank.persisted? && bank.code == bank_attrs[:code]
    # Update existing record
    bank.update!(bank_attrs)
    puts "✓ Updated bank: #{bank_attrs[:name]} (#{bank_attrs[:code]})"
  else
    # Create new record
    Bank.create!(bank_attrs)
    puts "✓ Created bank: #{bank_attrs[:name]} (#{bank_attrs[:code]})"
  end
end

puts ''
puts 'Banks Seeding Summary:'
puts "- Total banks: #{Bank.count}"
puts "- Active banks: #{Bank.active.count}"
puts "- Inactive banks: #{Bank.inactive.count}"
puts "- Major banks: #{Bank.where(code: %w[BCA MANDIRI BNI BRI]).count}"
puts "- Digital banks: #{Bank.where(code: %w[JAGO JENIUS DIGIBANK]).count}"
puts ''
puts 'Banks seeding completed!'

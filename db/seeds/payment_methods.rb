# frozen_string_literal: true

puts 'Seeding Payment Methods...'

# Clear existing payment methods
PaymentMethod.delete_all

payment_methods = [
  # E-Wallet Payment Methods
  {
    code: 'qris',
    display_name: 'QRIS (All E-Wallets)',
    type: 'e_wallet',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 0,
    fee_percent: 0.7,
    icon_url: 'https://cdn.example.com/icons/qris.svg',
    sort_order: 1,
    description: 'Pay with any e-wallet app using QR code (GoPay, OVO, DANA, ShopeePay, etc.)'
  },
  {
    code: 'gopay',
    display_name: 'GoPay',
    type: 'e_wallet',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 0,
    fee_percent: 2.0,
    icon_url: 'https://cdn.example.com/icons/gopay.svg',
    sort_order: 2,
    description: 'Pay directly with your GoPay balance'
  },
  {
    code: 'ovo',
    display_name: 'OVO',
    type: 'e_wallet',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 0,
    fee_percent: 1.5,
    icon_url: 'https://cdn.example.com/icons/ovo.svg',
    sort_order: 3,
    description: 'Pay with your OVO balance'
  },
  {
    code: 'dana',
    display_name: 'DANA',
    type: 'e_wallet',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 0,
    fee_percent: 1.5,
    icon_url: 'https://cdn.example.com/icons/dana.svg',
    sort_order: 4,
    description: 'Pay with your DANA balance'
  },
  {
    code: 'shopeepay',
    display_name: 'ShopeePay',
    type: 'e_wallet',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 0,
    fee_percent: 1.8,
    icon_url: 'https://cdn.example.com/icons/shopeepay.svg',
    sort_order: 5,
    description: 'Pay with your ShopeePay balance'
  },

  # Bank Transfer Payment Methods
  {
    code: 'bca_va',
    display_name: 'BCA Virtual Account',
    type: 'bank_transfer',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 4000,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/bca.svg',
    sort_order: 10,
    description: 'Transfer to BCA Virtual Account number'
  },
  {
    code: 'bni_va',
    display_name: 'BNI Virtual Account',
    type: 'bank_transfer',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 4000,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/bni.svg',
    sort_order: 11,
    description: 'Transfer to BNI Virtual Account number'
  },
  {
    code: 'bri_va',
    display_name: 'BRI Virtual Account',
    type: 'bank_transfer',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 4000,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/bri.svg',
    sort_order: 12,
    description: 'Transfer to BRI Virtual Account number'
  },
  {
    code: 'mandiri_va',
    display_name: 'Mandiri Virtual Account',
    type: 'bank_transfer',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 4000,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/mandiri.svg',
    sort_order: 13,
    description: 'Transfer to Mandiri Virtual Account number'
  },
  {
    code: 'permata_va',
    display_name: 'Permata Virtual Account',
    type: 'bank_transfer',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 4000,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/permata.svg',
    sort_order: 14,
    description: 'Transfer to Permata Virtual Account number'
  },

  # Credit Card Payment Methods
  {
    code: 'credit_card',
    display_name: 'Credit Card',
    type: 'credit_card',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 0,
    fee_percent: 2.9,
    icon_url: 'https://cdn.example.com/icons/credit_card.svg',
    sort_order: 20,
    description: 'Pay with Visa, Mastercard, or JCB credit card'
  },
  {
    code: 'credit_card_installment',
    display_name: 'Credit Card Installment',
    type: 'credit_card',
    payment_gateway: 'midtrans',
    enabled: false, # Can be enabled for high-value events
    fee_flat: 0,
    fee_percent: 3.5,
    icon_url: 'https://cdn.example.com/icons/credit_card_installment.svg',
    sort_order: 21,
    description: 'Pay with installment using credit card (3, 6, 12 months)'
  },

  # Convenience Store Payment Methods
  {
    code: 'indomaret',
    display_name: 'Indomaret',
    type: 'convenience_store',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 5000,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/indomaret.svg',
    sort_order: 30,
    description: 'Pay at any Indomaret store nationwide'
  },
  {
    code: 'alfamart',
    display_name: 'Alfamart',
    type: 'convenience_store',
    payment_gateway: 'midtrans',
    enabled: true,
    fee_flat: 5000,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/alfamart.svg',
    sort_order: 31,
    description: 'Pay at any Alfamart store nationwide'
  },

  # Alternative Gateway Examples (Xendit)
  {
    code: 'xendit_qris',
    display_name: 'QRIS via Xendit',
    type: 'e_wallet',
    payment_gateway: 'xendit',
    enabled: false, # Alternative gateway, can be enabled
    fee_flat: 0,
    fee_percent: 0.6,
    icon_url: 'https://cdn.example.com/icons/qris.svg',
    sort_order: 100,
    description: 'QRIS payment processed through Xendit gateway'
  },
  {
    code: 'xendit_va',
    display_name: 'Virtual Account via Xendit',
    type: 'bank_transfer',
    payment_gateway: 'xendit',
    enabled: false,
    fee_flat: 3500,
    fee_percent: 0.0,
    icon_url: 'https://cdn.example.com/icons/bank_transfer.svg',
    sort_order: 101,
    description: 'Bank transfer via Xendit Virtual Account'
  }
]

payment_methods.each do |payment_method_attrs|
  payment_method = PaymentMethod.find_or_create_by(code: payment_method_attrs[:code])

  if payment_method.persisted? && payment_method.code == payment_method_attrs[:code]
    # Update existing record
    payment_method.update!(payment_method_attrs)
    puts "✓ Updated payment method: #{payment_method_attrs[:display_name]} (#{payment_method_attrs[:code]})"
  else
    # Create new record
    PaymentMethod.create!(payment_method_attrs)
    puts "✓ Created payment method: #{payment_method_attrs[:display_name]} (#{payment_method_attrs[:code]})"
  end
end

puts ''
puts 'Payment Methods Seeding Summary:'
puts "- Total payment methods: #{PaymentMethod.count}"
puts "- Enabled payment methods: #{PaymentMethod.enabled.count}"
puts "- E-wallet methods: #{PaymentMethod.by_type('e_wallet').count}"
puts "- Bank transfer methods: #{PaymentMethod.by_type('bank_transfer').count}"
puts "- Credit card methods: #{PaymentMethod.by_type('credit_card').count}"
puts "- Convenience store methods: #{PaymentMethod.by_type('convenience_store').count}"
puts "- Midtrans gateway methods: #{PaymentMethod.by_gateway('midtrans').count}"
puts ''
puts 'Payment Methods seeding completed!'

# frozen_string_literal: true

class PayoutMethod
  include Mongoid::Document
  include Mongoid::Timestamps
  include StatusMethods
  include PayoutMethods::PinManagement
  include PayoutMethods::AccountMasking
  include PayoutMethods::WithdrawalRules
  include PayoutMethods::SingleActivePerUser
  include Searchable

  # Fields
  field :bank_account_no, type: String
  field :account_holder, type: String
  field :pin_hash, type: String
  field :withdrawal_rules, type: Hash, default: {}
  field :is_active, type: Boolean, default: true

  # Relationships
  belongs_to :user
  belongs_to :bank

  # Validations
  validates :bank_account_no, presence: true,
                              format: { with: /\A\d{8,20}\z/, message: 'must be 8-20 digits' }
  validates :account_holder, presence: true, length: { minimum: 2, maximum: 100 }

  # Indexes
  index({ user_id: 1, is_active: 1 })
  index({ bank_id: 1 })
  index({ bank_account_no: 1, bank_id: 1 }, { unique: true })

  # Scopes
  scope :by_user, ->(user) { where(user: user) }
  scope :with_bank, -> { includes(:bank) }

  # Class methods
  def self.searchable_fields
    %w[account_holder bank_account_no]
  end

  # Instance methods
  def bank_name
    bank&.name
  end

  def bank_code
    bank&.code
  end
end

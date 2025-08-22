# frozen_string_literal: true

class Bank
  include Mongoid::Document
  include Mongoid::Timestamps
  include StatusMethods
  include MongodbSearch::BankSearchable

  field :code, type: String
  field :name, type: String
  field :logo_url, type: String
  field :is_active, type: Boolean, default: true

  # MongoDB indexes for performance optimization
  index({ name: 1 }, { unique: true, sparse: true, background: true })
  index({ code: 1 }, { unique: true, sparse: true, background: true })
  index({ is_active: 1, sort_order: 1 }, { background: true })
  # Text search index for name
  index({ name: 'text' }, { background: true })

  validates :code, presence: true, uniqueness: true,
                   format: { with: /\A[A-Z0-9_]+\z/, message: 'must contain only uppercase letters, numbers, and underscores' }
  validates :name, presence: true

  scope :ordered, -> { order_by(name: :asc) }

  # Helper method to get available banks for selection
  def self.available_for_selection
    active.ordered
  end

  # Check if bank can be safely deactivated
  def can_be_deactivated?
    # Check for existing payout methods using this bank
    !PayoutMethod.where(bank: self).exists?
  end

  # Override deactivate! from StatusMethods to add safety check
  def deactivate!
    if can_be_deactivated?
      super
    else
      errors.add(:base, 'Cannot deactivate bank that is in use by existing payout methods')
      false
    end
  end
end

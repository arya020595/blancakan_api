# frozen_string_literal: true

class Bank
  include Mongoid::Document
  include Mongoid::Timestamps
  include StatusMethods
  include Searchable

  field :code, type: String
  field :name, type: String
  field :logo_url, type: String
  field :is_active, type: Boolean, default: true

  validates :code, presence: true, uniqueness: true,
                   format: { with: /\A[A-Z0-9_]+\z/, message: 'must contain only uppercase letters, numbers, and underscores' }
  validates :name, presence: true

  scope :ordered, -> { order_by(name: :asc) }

  # Define searchable fields for the Searchable concern
  def self.searchable_fields
    %w[name code]
  end

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

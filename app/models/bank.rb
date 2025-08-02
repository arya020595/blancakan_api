# frozen_string_literal: true

class Bank
  include Mongoid::Document
  include Mongoid::Timestamps
  include StatusMethods

  field :code, type: String
  field :name, type: String
  field :logo_url, type: String
  field :is_active, type: Boolean, default: true

  validates :code, presence: true, uniqueness: true,
                   format: { with: /\A[A-Z0-9_]+\z/, message: 'must contain only uppercase letters, numbers, and underscores' }
  validates :name, presence: true

  scope :ordered, -> { order_by(name: :asc) }

  # Search functionality using MongoDB regex search
  def self.search(query: '*', page: 1, per_page: 10)
    if query == '*' || query.blank?
      ordered.page(page).per(per_page)
    else
      where(
        '$or' => [
          { name: /#{Regexp.escape(query)}/i },
          { code: /#{Regexp.escape(query)}/i }
        ]
      ).ordered.page(page).per(per_page)
    end
  end

  # Helper method to get available banks for selection
  def self.available_for_selection
    active.ordered
  end

  # Check if bank can be safely deactivated
  def can_be_deactivated?
    # TODO: Add check for existing payout methods using this bank
    # For now, allow deactivation
    true
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

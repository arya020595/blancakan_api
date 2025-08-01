# frozen_string_literal: true

class PaymentMethod
  include Mongoid::Document
  include Mongoid::Timestamps

  field :code, type: String
  field :display_name, type: String
  field :type, type: String
  field :payment_gateway, type: String
  field :enabled, type: Boolean, default: true
  field :fee_flat, type: Integer, default: 0
  field :fee_percent, type: Float, default: 0.0
  field :icon_url, type: String
  field :sort_order, type: Integer, default: 0
  field :description, type: String

  # Enum for type
  TYPES = %w[e_wallet bank_transfer credit_card convenience_store].freeze

  validates :code, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9_]+\z/, message: 'must contain only lowercase letters, numbers, and underscores' }
  validates :display_name, :type, :payment_gateway, presence: true
  validates :fee_flat, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :fee_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :sort_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :type, inclusion: { in: TYPES, message: 'must be one of: %<value>s' }

  scope :enabled, -> { where(enabled: true) }
  scope :by_gateway, ->(gateway) { where(payment_gateway: gateway, enabled: true) }
  scope :ordered, -> { order_by(sort_order: :asc, display_name: :asc) }
  scope :by_type, ->(type) { where(type: type, enabled: true) }

  def self.types
    TYPES
  end

  # Search functionality using MongoDB text search
  def self.search(query: '*', page: 1, per_page: 10)
    if query == '*' || query.blank?
      ordered.page(page).per(per_page)
    else
      where(
        '$or' => [
          { display_name: /#{Regexp.escape(query)}/i },
          { code: /#{Regexp.escape(query)}/i },
          { type: /#{Regexp.escape(query)}/i },
          { payment_gateway: /#{Regexp.escape(query)}/i }
        ]
      ).ordered.page(page).per(per_page)
    end
  end

  # Calculate total fee for a given subtotal
  def calculate_fee(subtotal)
    flat_fee = fee_flat || 0
    percent_fee = ((fee_percent || 0.0) / 100.0 * subtotal).round
    flat_fee + percent_fee
  end

  # Helper method to get available payment methods for checkout
  def self.available_for_checkout(gateway = nil)
    scope = enabled.ordered
    scope = scope.by_gateway(gateway) if gateway.present?
    scope
  end
end

# frozen_string_literal: true

class EventType
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields matching the provided schema
  field :name, type: String
  field :slug, type: String
  field :icon_url, type: String
  field :description, type: String
  field :is_active, type: Boolean, default: true
  field :sort_order, type: Integer, default: 0

  # Associations
  has_many :events

  # MongoDB indexes for performance optimization
  index({ name: 1 }, { unique: true, sparse: true, background: true })
  index({ slug: 1 }, { unique: true, sparse: true, background: true })
  index({ is_active: 1, sort_order: 1 }, { background: true })
  # Text search index for name and description
  index({ name: 'text', description: 'text' }, { background: true })

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :sort_order, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :generate_slug, on: :create

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(:sort_order, :name) }

  # Class methods
  def self.for_selection
    active.ordered.pluck(:name, :id)
  end

  private

  def generate_slug
    return if name.blank?

    self.slug = name.parameterize
  end
end

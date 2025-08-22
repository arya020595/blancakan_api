# frozen_string_literal: true

class Role
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::RoleSearchable

  field :name, type: String
  field :description, type: String

  has_many :users
  has_many :permissions, dependent: :destroy

  index({ name: 1 }, { unique: true })

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  scope :ordered, -> { order_by(name: :asc) }

  # Superadmin: Can manage everything.
  # Admin: Manages events and users but cannot modify superadmin settings.
  # organizer: Can create and manage their own events.
  # premium_organizer: Can create events with advanced features (ticketing, subdomains, UI customization).
end

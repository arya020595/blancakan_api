class Role
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String

  has_and_belongs_to_many :users
  has_many :permissions, dependent: :destroy

  index({ name: 1 }, { unique: true })

  validates :name, presence: true, uniqueness: true

  # Superadmin: Can manage everything.
  # Admin: Manages events and users but cannot modify superadmin settings.
  # organizer: Can create and manage their own events.
  # premium_organizer: Can create events with advanced features (ticketing, subdomains, UI customization).
end

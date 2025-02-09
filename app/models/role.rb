class Role
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :users
  belongs_to :resource, polymorphic: true, optional: true # Make resource optional

  field :name, type: String

  index({
          name: 1,
          resource_type: 1,
          resource_id: 1
        },
        { unique: true })

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  # Superadmin: Can manage everything.
  # Admin: Manages events and users but cannot modify superadmin settings.
  # organizer: Can create and manage their own events.
  # premium_organizer: Can create events with advanced features (ticketing, subdomains, UI customization).
end

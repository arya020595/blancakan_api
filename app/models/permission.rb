class Permission
  include Mongoid::Document
  include Mongoid::Timestamps

  field :action, type: String # Example: "read", "create"
  field :subject_class, type: String # Example: "Event", "User"
  field :conditions, type: Hash, default: {} # Optional: { "user_id": "user.id" }

  belongs_to :role

  validates :action, :subject_class, presence: true
  validates :action,
            uniqueness: { scope: %i[subject_class role_id],
                          message: I18n.t('mongoid.errors.models.permission.attributes.action.duplicate_permission') }
end

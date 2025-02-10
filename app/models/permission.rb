class Permission
  include Mongoid::Document
  include Mongoid::Timestamps

  field :action, type: String # Example: "read", "create"
  field :subject_class, type: String # Example: "Event", "User"
  field :conditions, type: Hash, default: {} # Optional: { "user_id": "user.id" }

  belongs_to :role

  validates :action, :subject_class, presence: true
end

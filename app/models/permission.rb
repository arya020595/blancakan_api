# frozen_string_literal: true

class Permission
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::PermissionSearchable
  include MongodbSearch::PermissionSearchable

  field :action, type: String # Example: "read", "create"
  field :subject_class, type: String # Example: "Event", "User"
  field :conditions, type: Hash, default: {} # Optional: { "user_id": "user.id" }

  # MongoDB indexes for performance optimization
  index({ action: 1, subject_class: 1, role_id: 1 }, { unique: true, background: true })
  index({ role_id: 1 }, { background: true })

  belongs_to :role

  validates :action, :subject_class, presence: true
  validates :action,
            uniqueness: { scope: %i[subject_class role_id],
                          message: I18n.t('mongoid.errors.models.permission.attributes.action.duplicate_permission') }

  scope :ordered, -> { order_by(action: :asc, subject_class: :asc) }
end

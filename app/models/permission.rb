class Permission
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::PermissionSearchable

  field :action, type: String # Example: "read", "create"
  field :subject_class, type: String # Example: "Event", "User"
  field :conditions, type: Hash, default: {} # Optional: { "user_id": "user.id" }

  belongs_to :role

  validates :action, :subject_class, presence: true
  validates :action,
            uniqueness: { scope: %i[subject_class role_id],
                          message: I18n.t('mongoid.errors.models.permission.attributes.action.duplicate_permission') }
  after_save :enqueue_reindex_job
  after_destroy :enqueue_reindex_job

  private

  def enqueue_reindex_job
    ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
  end
end

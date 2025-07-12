class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::CategorySearchable
  include CategoryEventQueries

  field :name, type: String
  field :description, type: String
  field :is_active, type: Boolean, default: false
  field :parent_id, type: BSON::ObjectId

  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: :parent_id

  # MongoDB indexes for performance optimization
  index({ name: 1 }, { unique: true, sparse: true, background: true })
  index({ is_active: 1 }, { background: true })
  index({ parent_id: 1 }, { sparse: true, background: true })
  # Text search index for name and description
  index({ name: 'text', description: 'text' }, { background: true })

  validates :name, presence: true, uniqueness: true

  scope :main_categories, -> { where(parent_id: nil) }
  scope :subcategories, -> { where(:parent_id.ne => nil) }
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }

  after_save :enqueue_reindex_job
  after_destroy :enqueue_reindex_job

  private

  def enqueue_reindex_job
    ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
  end
end

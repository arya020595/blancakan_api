# frozen_string_literal: true

class Organizer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::OrganizerSearchable

  # Concerns for separation of concerns
  include Organizers::ProfileMethods
  include StatusMethods
  include Organizers::EventMethods
  include Organizers::SearchMethods

  # Fields
  field :handle, type: String
  field :name, type: String
  field :description, type: String
  field :avatar, type: String
  field :contact_phone, type: String
  field :is_active, type: Boolean, default: true

  # Associations
  belongs_to :user
  has_many :events, foreign_key: :organizer_id, class_name: 'Event'

  # CarrierWave
  mount_uploader :avatar, ImageUploader

  # MongoDB indexes for performance optimization
  index({ user_id: 1 }, { unique: true, background: true })
  index({ handle: 1 }, { unique: true, sparse: true, background: true })
  index({ is_active: 1 }, { background: true })
  index({ name: 1 }, { background: true })
  index({ created_at: 1 }, { background: true })

  # Text search index for name and description
  index({ name: 'text', description: 'text' }, { background: true })

  # Validations
  validates :user, presence: true, uniqueness: true
  validates :handle, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }, format: {
    with: /\A@[a-zA-Z0-9_]+\z/,
    message: 'must start with @ and contain only letters, numbers, and underscores'
  }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :contact_phone, format: {
    with: /\A\+?[1-9]\d{1,14}\z/,
    message: 'must be a valid phone number'
  }, allow_blank: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_handle, ->(handle) { where(handle: handle.downcase) }
  scope :search_by_name, ->(query) { where(name: /#{Regexp.escape(query)}/i) }

  # Callbacks
  before_update :destroy_previous_avatar_if_changed
  before_destroy :destroy_current_avatar
  after_save :enqueue_reindex_job
  after_destroy :enqueue_reindex_job

  private

  def image_service
    @image_service ||= V1::Organizers::ImageService.new(self)
  end

  def destroy_previous_avatar_if_changed
    image_service.destroy_previous_image_if_changed
  end

  def destroy_current_avatar
    image_service.destroy_current_image
  end

  def enqueue_reindex_job
    ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
  end
end

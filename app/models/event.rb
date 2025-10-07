# frozen_string_literal: true

class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include AASM
  include CarrierWave::Mongoid
  include Elasticsearch::EventSearchable
  include MongodbSearch::EventSearchable

  # Concerns for separation of concerns
  include Events::DateTimeValidations

  # Fields - only data definition
  field :title, type: String
  field :slug, type: String
  field :description, type: String
  field :cover_image, type: String
  field :status, type: String, default: 'draft'
  field :location_type, type: String
  field :location, type: Hash
  field :start_date, type: Date
  field :start_time, type: Time
  field :end_date, type: Date
  field :end_time, type: Time
  field :timezone, type: String, default: 'UTC'
  field :is_paid, type: Boolean, default: false
  field :published_at, type: Time
  field :canceled_at, type: Time

  # Associations
  belongs_to :organizer, class_name: 'Organizer'
  belongs_to :event_type
  has_and_belongs_to_many :categories
  has_many :ticket_types

  # MongoDB indexes for performance optimization
  # Based on "MongoDB: The Definitive Guide" - index common query patterns
  index({ slug: 1 }, { unique: true, sparse: true, background: true })
  index({ status: 1, start_date: 1 }, { background: true })
  index({ category_ids: 1, status: 1 }, { background: true })
  index({ organizer_id: 1, status: 1 }, { background: true })
  index({ event_type_id: 1, status: 1 }, { background: true })
  index({ start_date: 1, end_date: 1 }, { background: true })
  index({ published_at: 1 }, { sparse: true, background: true })
  index({ timezone: 1, start_date: 1 }, { background: true })
  # Text search index for title and description
  index({ title: 'text', description: 'text' }, { background: true })

  # Database integrity validations - fallback guardrails
  validates :slug, presence: true, uniqueness: true
  validates :event_type, presence: true
  validates :organizer, presence: true

  # Slug configuration using mongoid-slug
  slug :title, history: true

  # CarrierWave
  mount_uploader :cover_image, ImageUploader

  # Callbacks
  before_update :destroy_previous_image_if_changed
  before_destroy :destroy_current_image
  after_save :enqueue_reindex_job
  after_destroy :enqueue_reindex_job

  # State machine
  aasm column: :status do
    state :draft, initial: true
    state :published, :cancelled, :rejected

    event :publish do
      transitions from: :draft, to: :published, after: :set_published_at
      after { notification_service.send_published_notification }
    end

    event :cancel do
      transitions from: %i[draft published], to: :cancelled, after: :set_canceled_at
      after { notification_service.send_canceled_notification }
    end

    event :reject do
      transitions from: %i[draft published], to: :rejected
      after { notification_service.send_rejected_notification }
    end
  end

  # Delegate datetime operations to service object (Fowler's Delegation pattern)
  delegate :start_datetime, :end_datetime, :start_datetime_in, :end_datetime_in,
           :start_datetime_utc, :end_datetime_utc, :duration_in_hours,
           :happening_now?, :local_start_time_for, :local_end_time_for,
           to: :datetime_service

  private

  def datetime_service
    @datetime_service ||= V1::Events::DateTimeService.new(self)
  end

  def notification_service
    @notification_service ||= V1::Events::NotificationService.new(self)
  end

  def image_service
    @image_service ||= V1::Events::ImageService.new(self)
  end

  def set_published_at
    return if update(published_at: Time.current)

    errors.add(:base, I18n.t('event.errors.failed_to_update_published_at'))
    raise ActiveRecord::Rollback
  end

  def set_canceled_at
    return if update(canceled_at: Time.current)

    errors.add(:base, I18n.t('event.errors.failed_to_update_canceled_at'))
    raise ActiveRecord::Rollback
  end

  def destroy_previous_image_if_changed
    image_service.destroy_previous_image_if_changed
  end

  def destroy_current_image
    image_service.destroy_current_image
  end

  def enqueue_reindex_job
    ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
  end
end

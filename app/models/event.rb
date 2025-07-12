# frozen_string_literal: true

class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include CarrierWave::Mongoid
  include Elasticsearch::EventSearchable

  # Concerns for separation of concerns
  include EventSlugGenerator
  include EventDateTimeValidations

  # Fields - only data definition
  field :title, type: String
  field :slug, type: String
  field :short_id, type: String
  field :description, type: String
  field :cover_image_url, type: String
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
  belongs_to :organizer, class_name: 'User'
  belongs_to :event_type
  has_and_belongs_to_many :categories

  # MongoDB indexes for performance optimization
  # Based on "MongoDB: The Definitive Guide" - index common query patterns
  index({ slug: 1 }, { unique: true, sparse: true, background: true })
  index({ short_id: 1 }, { unique: true, sparse: true, background: true })
  index({ status: 1, start_date: 1 }, { background: true })
  index({ category_ids: 1, status: 1 }, { background: true })
  index({ organizer_id: 1, status: 1 }, { background: true })
  index({ event_type_id: 1, status: 1 }, { background: true })
  index({ start_date: 1, end_date: 1 }, { background: true })
  index({ published_at: 1 }, { sparse: true, background: true })
  index({ timezone: 1, start_date: 1 }, { background: true })
  # Text search index for title and description
  index({ title: 'text', description: 'text' }, { background: true })

  # Basic validations - complex ones moved to concerns
  validates :title, :start_date, :start_time, :end_date, :end_time, :description, :location_type, :timezone,
            presence: true
  validates :slug, presence: true, uniqueness: true
  validates :short_id, presence: true, uniqueness: true, length: { in: 6..8 }
  validates :location_type, inclusion: { in: %w[online offline hybrid] }
  validates :timezone, inclusion: {
    in: lambda { |_|
      # Use direct ActiveSupport::TimeZone during seeding to avoid cache issues
      ActiveSupport::TimeZone.all.map(&:name)
    },
    message: 'is not a valid timezone'
  }
  validates :event_type, presence: true

  # CarrierWave
  mount_uploader :cover_image_url, ImageUploader

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
      after { send_notification(I18n.t('event.notifications.published', title: title)) }
    end

    event :cancel do
      transitions from: %i[draft published], to: :cancelled, after: :set_canceled_at
      after { send_notification(I18n.t('event.notifications.canceled', title: title)) }
    end

    event :reject do
      before { authorize_admin_action }
      transitions from: %i[draft published], to: :rejected
      after { send_notification(I18n.t('event.notifications.rejected', title: title)) }
    end
  end

  # Delegate datetime operations to service object (Fowler's Delegation pattern)
  delegate :start_datetime, :end_datetime, :start_datetime_in, :end_datetime_in,
           :start_datetime_utc, :end_datetime_utc, :duration_in_hours,
           :happening_now?, :local_start_time_for, :local_end_time_for,
           to: :datetime_service

  private

  def datetime_service
    @datetime_service ||= EventDateTimeService.new(self)
  end

  def authorize_admin_action
    return if User.current.has_role?(:admin) || User.current.has_role?(:superadmin)

    errors.add(:base, I18n.t('event.errors.not_authorized'))
    throw(:abort)
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

  def send_notification(message)
    puts "[NOTIFICATION] #{message}"
  end

  def destroy_previous_image_if_changed
    return unless cover_image_url_changed?

    Cloudinary::Uploader.destroy(cover_image_url_was.file.public_id) if cover_image_url_was.present?
  end

  def destroy_current_image
    Cloudinary::Uploader.destroy(cover_image_url.file.public_id) if cover_image_url.present?
  end

  def enqueue_reindex_job
    ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
  end
end

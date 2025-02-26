class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include CarrierWave::Mongoid
  include Searchable

  field :title, type: String
  field :description, type: String
  field :location, type: String
  field :starts_at, type: DateTime
  field :ends_at, type: DateTime
  field :published_at, type: Time
  field :canceled_at, type: Time
  field :status, type: String
  field :organizer, type: String
  field :image, type: String

  belongs_to :category
  belongs_to :user

  validates :title, :starts_at, :ends_at, :description, :location, :organizer, presence: true
  validate :starts_at_cannot_be_in_the_past
  validate :starts_at_before_ends_at

  mount_uploader :image, ImageUploader

  before_update :destroy_previous_image_if_changed
  before_destroy :destroy_current_image

  after_save :reindex_event
  after_destroy :reindex_event

  aasm column: :status do
    state :draft, initial: true
    state :published, :canceled

    event :publish do
      transitions from: :draft, to: :published, after: :set_published_at

      after do
        send_notification(I18n.t('event.notifications.published', title: title))
      end
    end

    event :cancel do
      transitions from: %i[draft published], to: :canceled, after: :set_canceled_at

      after do
        send_notification(I18n.t('event.notifications.canceled', title: title))
      end
    end
  end

  private

  def starts_at_cannot_be_in_the_past
    return unless starts_at.present? && starts_at < DateTime.now

    errors.add(:starts_at, I18n.t('event.errors.starts_at_past'))
  end

  def starts_at_before_ends_at
    return unless starts_at.present? && ends_at.present? && starts_at > ends_at

    errors.add(:starts_at, I18n.t('event.errors.starts_at_before_ends_at'))
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
    return unless image_changed?

    Cloudinary::Uploader.destroy(image_was.file.public_id) if image_was.present?
  end

  def destroy_current_image
    Cloudinary::Uploader.destroy(image.file.public_id) if image.present?
  end

  def reindex_event
    __elasticsearch__.index_document
  end
end

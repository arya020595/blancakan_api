class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include CarrierWave::Mongoid

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

  mount_uploader :image, ImageUploader

  before_update :destroy_previous_image_if_changed
  before_destroy :destroy_current_image

  aasm column: :status do
    state :draft, initial: true
    state :published, :canceled

    event :publish do
      transitions from: :draft, to: :published, after: :set_published_at

      after do
        send_notification("Event '#{title}' has been published!")
      end
    end

    event :cancel do
      transitions from: %i[draft published], to: :canceled, after: :set_canceled_at

      after do
        send_notification("Event '#{title}' has been canceled!")
      end
    end
  end

  private

  def set_published_at
    return if update(published_at: Time.current)

    errors.add(:base, 'Failed to update published_at')
    raise ActiveRecord::Rollback
  end

  def set_canceled_at
    return if update(canceled_at: Time.current)

    errors.add(:base, 'Failed to update canceled_at')
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
end

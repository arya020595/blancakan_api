class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  include CarrierWave::Mongoid

  field :title, type: String
  field :description, type: String
  field :location, type: String
  field :starts_at, type: Time
  field :ends_at, type: Time
  field :published_at, type: Time
  field :canceled_at, type: Time
  field :status, type: String
  field :image, type: String

  belongs_to :category

  validates :title, :starts_at, :ends_at, :category, presence: true

  mount_uploader :image, ImageUploader

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
end

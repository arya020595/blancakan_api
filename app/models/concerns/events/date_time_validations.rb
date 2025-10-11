# frozen_string_literal: true

module Events
  module DateTimeValidations
    extend ActiveSupport::Concern

    included do
      validate :starts_at_cannot_be_in_the_past
      validate :starts_at_before_ends_at
      validate :event_duration_is_reasonable
    end

    private

    # Timezone-aware validations (based on Rails guides best practices)
    # Always compare in UTC to avoid timezone confusion
    def starts_at_cannot_be_in_the_past
      return unless starts_at_utc.present?

      # Compare in UTC to avoid timezone confusion
      return unless starts_at_utc < Time.current.utc

      errors.add(:starts_at_local, I18n.t('event.errors.start_datetime_past'))
    end

    def starts_at_before_ends_at
      return unless starts_at_utc.present? && ends_at_utc.present?

      return unless starts_at_utc >= ends_at_utc

      errors.add(:starts_at_local, I18n.t('event.errors.start_before_end'))
    end

    # Enhanced validation for international events
    # Ensure events don't exceed reasonable duration (30 days)
    def event_duration_is_reasonable
      return unless starts_at_utc.present? && ends_at_utc.present?

      duration_days = ((ends_at_utc - starts_at_utc) / 1.day).to_i
      return if duration_days <= 30 # Valid event (up to 30 days)

      errors.add(:ends_at_local, I18n.t('event.errors.invalid_date_range'))
    end

    def datetime_service
      @datetime_service ||= V1::Events::DateTimeService.new(self)
    end
  end
end

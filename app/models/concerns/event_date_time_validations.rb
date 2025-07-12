# frozen_string_literal: true

module EventDateTimeValidations
  extend ActiveSupport::Concern

  included do
    validate :start_datetime_cannot_be_in_the_past
    validate :start_datetime_before_end_datetime
    validate :start_and_end_on_same_day_if_single_day_event
  end

  private

  # Timezone-aware validations (based on Rails guides best practices)
  def start_datetime_cannot_be_in_the_past
    return unless datetime_service.start_datetime.present?

    # Compare in UTC to avoid timezone confusion
    return unless datetime_service.start_datetime_utc < Time.current.utc

    errors.add(:start_date, I18n.t('event.errors.start_datetime_past'))
  end

  def start_datetime_before_end_datetime
    return unless datetime_service.start_datetime.present? && datetime_service.end_datetime.present?

    return unless datetime_service.start_datetime_utc >= datetime_service.end_datetime_utc

    errors.add(:start_date, I18n.t('event.errors.start_before_end'))
  end

  # Enhanced validation for international events
  def start_and_end_on_same_day_if_single_day_event
    return unless start_date.present? && end_date.present?
    return if start_date == end_date # Valid single-day event
    return if (end_date - start_date).to_i <= 30 # Valid multi-day event (up to 30 days)

    errors.add(:end_date, I18n.t('event.errors.invalid_date_range'))
  end

  def datetime_service
    @datetime_service ||= EventDateTimeService.new(self)
  end
end

# frozen_string_literal: true

class EventNotificationService
  def initialize(event)
    @event = event
  end

  def send_published_notification
    send_notification(I18n.t('event.notifications.published', title: @event.title))
  end

  def send_canceled_notification
    send_notification(I18n.t('event.notifications.canceled', title: @event.title))
  end

  def send_rejected_notification
    send_notification(I18n.t('event.notifications.rejected', title: @event.title))
  end

  private

  def send_notification(message)
    puts "[NOTIFICATION] #{message}"
    # TODO: Replace with proper notification service (email, push, etc.)
  end
end

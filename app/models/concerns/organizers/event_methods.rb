# frozen_string_literal: true

module Organizers
  module EventMethods
    extend ActiveSupport::Concern

    # Instance methods for organizer event management
    def events_count
      events.count
    end

    def published_events_count
      events.where(status: 'published').count
    end

    def active_events_count
      upcoming_events.count
    end

    def upcoming_events
      events.where(
        status: 'published',
        start_date: { '$gte' => Date.current }
      ).order_by(start_date: :asc)
    end

    def past_events
      events.where(
        status: 'published',
        end_date: { '$lt' => Date.current }
      ).order_by(start_date: :desc)
    end

    def draft_events
      events.where(status: 'draft').order_by(created_at: :desc)
    end

    def cancelled_events
      events.where(status: 'cancelled').order_by(updated_at: :desc)
    end
  end
end

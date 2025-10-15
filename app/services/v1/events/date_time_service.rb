# frozen_string_literal: true

module V1
  module Events
    # Service for datetime operations on events
    # Works with the new combined datetime fields (starts_at_local, starts_at_utc, etc.)
    class DateTimeService
      def initialize(event)
        @event = event
      end

      # Duration in hours between start and end
      def duration_in_hours
        return nil unless @event.starts_at_utc && @event.ends_at_utc

        ((@event.ends_at_utc - @event.starts_at_utc) / 1.hour).round(2)
      end

      # Check if event is currently happening (timezone-aware)
      def happening_now?
        return false unless @event.starts_at_utc && @event.ends_at_utc

        Time.current.utc.between?(@event.starts_at_utc, @event.ends_at_utc)
      end

      # Get start time in a specific timezone
      def local_start_time_for(timezone)
        return nil unless @event.starts_at_utc

        @event.starts_at_utc.in_time_zone(timezone)
      end

      # Get end time in a specific timezone
      def local_end_time_for(timezone)
        return nil unless @event.ends_at_utc

        @event.ends_at_utc.in_time_zone(timezone)
      end
    end
  end
end

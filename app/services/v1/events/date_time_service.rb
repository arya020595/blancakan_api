# frozen_string_literal: true

module V1
  module Events
    class DateTimeService
      def initialize(event)
        @event = event
      end

      def start_datetime
        return nil unless @event.start_date && @event.start_time

        combine_date_time(@event.start_date, @event.start_time)
      end

      def end_datetime
        return nil unless @event.end_date && @event.end_time

        combine_date_time(@event.end_date, @event.end_time)
      end

      def start_datetime_in(timezone)
        return nil unless start_datetime

        start_datetime.in_time_zone(timezone)
      end

      def end_datetime_in(timezone)
        return nil unless end_datetime

        end_datetime.in_time_zone(timezone)
      end

      def start_datetime_utc
        return nil unless start_datetime

        start_datetime.utc
      end

      def end_datetime_utc
        return nil unless end_datetime

        end_datetime.utc
      end

      def duration_in_hours
        return nil unless start_datetime && end_datetime

        ((end_datetime - start_datetime) / 1.hour).round(2)
      end

      def happening_now?
        return false unless start_datetime && end_datetime

        Time.current.between?(start_datetime, end_datetime)
      end

      def local_start_time_for(timezone)
        return nil unless start_datetime

        start_datetime.in_time_zone(timezone)
      end

      def local_end_time_for(timezone)
        return nil unless end_datetime

        end_datetime.in_time_zone(timezone)
      end

      private

      def combine_date_time(date, time)
        DateTime.new(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.min,
          time.sec,
          time.zone
        ).in_time_zone(@event.timezone)
      end
    end
  end
end

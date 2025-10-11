# frozen_string_literal: true

module V1
  module Event
    class EventForm < ApplicationForm
      attribute :title, :string
      attribute :description, :string
      attribute :starts_at_local, :datetime  # Combined datetime from frontend
      attribute :ends_at_local, :datetime    # Combined datetime from frontend
      attribute :location_type, :string
      attribute :location
      attribute :timezone, :string
      attribute :organizer_id, :string
      attribute :event_type_id, :string
      attribute :category_ids
      attribute :cover_image # File upload handled by CarrierWave
      attribute :status, :string
      attribute :is_paid, :boolean

      def initialize(params = {})
        super(params)
        @contract = ::V1::Event::EventContract.new
      end

      def valid?
        @validation_result = @contract.call(sanitized_attributes)
        @validation_result.success?
      end

      def errors
        return @errors if defined?(@errors)

        raise 'You must call `valid?` before accessing `errors`' unless @validation_result

        @errors = ActiveModel::Errors.new(self).tap do |am_errors|
          @validation_result.errors.to_h.each do |field, messages|
            Array(messages).each { |msg| am_errors.add(field, msg) }
          end
        end
      end

      # Sanitized and processed attributes
      def sanitized_attributes
        attrs = {
          title: strip_string(title),
          description: strip_string(description),
          starts_at_local: parse_datetime(starts_at_local),
          ends_at_local: parse_datetime(ends_at_local),
          location_type: strip_string(location_type),
          location: location,
          timezone: strip_string(timezone) || 'Asia/Jakarta', # Default to Jakarta
          organizer_id: organizer_id,
          event_type_id: event_type_id,
          category_ids: sanitize_array(category_ids),
          cover_image: cover_image, # File upload handled by CarrierWave
          is_paid: is_paid
        }

        attrs.compact
      end
    end
  end
end

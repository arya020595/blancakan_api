# frozen_string_literal: true

module V1
  module Event
    class EventForm
      include ActiveModel::Model

      attr_accessor :name, :description, :start_date, :end_date, :location, :organizer_id, :event_type_id, :category_ids

      def initialize(params = {})
        super(params)
        @contract = ::V1::Event::EventContract.new
      end

      def valid?
        @validation_result = @contract.call(attributes)
        @validation_result.success?
      end

      def errors
        raise 'You must call `valid?` before accessing `errors`' unless @validation_result

        ActiveModel::Errors.new(self).tap do |am_errors|
          @validation_result.errors.to_h.each do |field, messages|
            Array(messages).each { |msg| am_errors.add(field, msg) }
          end
        end
      end

      def attributes
        {
          name: name,
          description: description,
          start_date: start_date,
          end_date: end_date,
          location: location,
          organizer_id: organizer_id,
          event_type_id: event_type_id,
          category_ids: category_ids
        }
      end
    end
  end
end

# frozen_string_literal: true

module V1
  module TicketType
    class TicketTypeForm < ApplicationForm
      attribute :event_id, :string
      attribute :name, :string
      attribute :description, :string
      attribute :price, :integer
      attribute :quota, :integer
      attribute :available_from, :datetime
      attribute :available_until, :datetime
      attribute :valid_on, :datetime
      attribute :is_active, :boolean, default: true
      attribute :sort_order, :integer
      attribute :metadata, :string

      def initialize(params = {})
        super(params)
        @contract = ::V1::TicketType::TicketTypeContract.new
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

      def sanitized_attributes
        {
          event_id: event_id,
          name: strip_string(name),
          description: strip_string(description),
          price: price,
          quota: quota,
          available_from: parse_datetime(available_from),
          available_until: parse_datetime(available_until),
          valid_on: parse_datetime(valid_on),
          is_active: is_active,
          sort_order: sort_order,
          metadata: strip_string(metadata)
        }.compact
      end

      alias attributes sanitized_attributes
    end
  end
end

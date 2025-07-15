# frozen_string_literal: true

module V1
  module EventType
    class EventTypeForm
      include ActiveModel::Model

      attr_accessor :name, :slug, :icon_url, :description, :is_active, :sort_order

      def initialize(params = {})
        super(params)
        @contract = ::V1::EventType::EventTypeContract.new

        # Set default values
        self.is_active = true if is_active.nil?
        self.sort_order = 0 if sort_order.nil?
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
          slug: slug,
          icon_url: icon_url,
          description: description,
          is_active: is_active,
          sort_order: sort_order
        }.compact
      end
    end
  end
end

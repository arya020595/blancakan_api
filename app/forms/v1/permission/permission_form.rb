# frozen_string_literal: true

module V1
  module Permission
    class PermissionForm
      include ActiveModel::Model

      attr_accessor :action, :subject_class, :conditions, :role_id
      attr_reader :conditions_parse_error

      def initialize(params = {})
        super(params)
        @contract = ::V1::Permission::PermissionContract.new
        @conditions_parse_error = false
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
          action: action,
          subject_class: subject_class,
          conditions: parse_conditions(conditions),
          role_id: role_id
        }.compact
      end

      private

      def parse_conditions(conditions_input)
        return nil if conditions_input.blank?
        return conditions_input if conditions_input.is_a?(Hash)
        
        # Try to parse as JSON string
        begin
          JSON.parse(conditions_input)
        rescue JSON::ParserError
          @conditions_parse_error = true
          conditions_input # Return original value to allow validation to catch it
        end
      end
    end
  end
end

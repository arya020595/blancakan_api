# frozen_string_literal: true

module V1
  module Bank
    class BankForm
      include ActiveModel::Model

      attr_accessor :code, :name, :logo_url, :is_active

      def initialize(params = {})
        super(params)
        @contract = ::V1::Bank::BankContract.new

        # Set default values following the model defaults
        self.is_active = true if is_active.nil?

        # Convert code to uppercase for consistency
        self.code = code.upcase if code.present?
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
          code: code,
          name: name,
          logo_url: logo_url,
          is_active: is_active
        }.compact
      end
    end
  end
end

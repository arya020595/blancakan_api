# frozen_string_literal: true

module V1
  module PaymentMethod
    class PaymentMethodForm
      include ActiveModel::Model

      attr_accessor :code, :display_name, :type, :payment_gateway, :enabled, :fee_flat,
                    :fee_percent, :icon_url, :sort_order, :description

      def initialize(params = {})
        super(params)
        @contract = ::V1::PaymentMethod::PaymentMethodContract.new

        # Set default values following the model defaults
        self.enabled = true if enabled.nil?
        self.fee_flat = 0 if fee_flat.nil?
        self.fee_percent = 0.0 if fee_percent.nil?
        self.sort_order = 0 if sort_order.nil?

        # Convert fee_flat to integer if it's a string or float
        self.fee_flat = fee_flat.to_i if fee_flat.present?
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
          display_name: display_name,
          type: type,
          payment_gateway: payment_gateway,
          enabled: enabled,
          fee_flat: fee_flat,
          fee_percent: fee_percent,
          icon_url: icon_url,
          sort_order: sort_order,
          description: description
        }.compact
      end
    end
  end
end

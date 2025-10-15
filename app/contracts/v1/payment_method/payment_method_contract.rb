# frozen_string_literal: true

module V1
  module PaymentMethod
    class PaymentMethodContract < Dry::Validation::Contract
      params do
        required(:code).filled(:string)
        required(:display_name).filled(:string)
        required(:type).filled(:string)
        required(:payment_gateway).filled(:string)
        optional(:enabled).maybe(:bool)
        optional(:fee_flat).maybe(:integer)
        optional(:fee_percent).maybe(:float)
        optional(:icon_url).maybe(:string)
        optional(:sort_order).maybe(:integer)
        optional(:description).maybe(:string)
      end

      rule(:type) do
        unless ::PaymentMethod::TYPES.include?(value)
          key.failure('must be one of: e_wallet, bank_transfer, credit_card, convenience_store')
        end
      end

      rule(:code) do
        if value && !value.match?(/\A[a-z0-9_]+\z/)
          key.failure('must be unique and contain only lowercase letters, numbers, and underscores')
        end
      end

      rule(:fee_flat) do
        key.failure('must be greater than or equal to 0 (in smallest currency unit)') if value && value < 0
      end

      rule(:fee_percent) do
        key.failure('must be between 0 and 100 percent') if value && (value < 0 || value > 100)
      end

      rule(:sort_order) do
        key.failure('must be greater than or equal to 0') if value && value < 0
      end
    end
  end
end

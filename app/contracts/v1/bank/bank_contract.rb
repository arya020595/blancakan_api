# frozen_string_literal: true

module V1
  module Bank
    class BankContract < Dry::Validation::Contract
      params do
        required(:code).filled(:string)
        required(:name).filled(:string)
        optional(:logo_url).maybe(:string)
        optional(:is_active).maybe(:bool)
      end

      rule(:code) do
        if value && !value.match?(/\A[A-Z0-9_]+\z/)
          key.failure('must contain only uppercase letters, numbers, and underscores')
        end
      end

      rule(:logo_url) do
        if value.present?
          uri = begin
            URI.parse(value)
          rescue StandardError
            nil
          end
          key.failure('must be a valid URL') unless uri&.is_a?(URI::HTTP)
        end
      end
    end
  end
end

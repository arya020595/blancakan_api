# frozen_string_literal: true

module V1
  module PayoutMethod
    class PayoutMethodContract < Dry::Validation::Contract
      params do
        required(:bank_id).filled(:string)
        required(:bank_account_no).filled(:string)
        required(:account_holder).filled(:string)
        required(:pin).filled(:string)
        optional(:withdrawal_rules).maybe(:hash)
        optional(:is_active).maybe(:bool)
      end

      rule(:bank_id) do
        bank = Bank.find(value)
        key.failure('bank not found') unless bank&.is_active?
      rescue Mongoid::Errors::DocumentNotFound
        key.failure('bank not found')
      rescue StandardError
        key.failure('invalid bank ID format')
      end

      rule(:bank_account_no) do
        key.failure('must be 8-20 digits') if value && !value.match?(/\A\d{8,20}\z/)
      end

      rule(:account_holder) do
        if value
          if value.length < 2
            key.failure('must be at least 2 characters')
          elsif value.length > 100
            key.failure('must be at most 100 characters')
          elsif !value.match?(/\A[a-zA-Z\s.'-]+\z/)
            key.failure('must contain only letters, spaces, periods, apostrophes, and hyphens')
          end
        end
      end

      rule(:pin) do
        if value
          if value.length < 4
            key.failure('must be at least 4 digits')
          elsif value.length > 6
            key.failure('must be at most 6 digits')
          elsif !value.match?(/\A\d+\z/)
            key.failure('must contain only digits')
          end
        end
      end

      rule(:withdrawal_rules) do
        if value.present?
          # Validate minimum withdrawal amount
          if value['min'].present?
            min_amount = value['min']
            unless min_amount.is_a?(Numeric) && min_amount >= 0
              key.failure('minimum withdrawal amount must be a non-negative number')
            end
          end

          # Validate maximum withdrawal amount
          if value['max'].present?
            max_amount = value['max']
            unless max_amount.is_a?(Numeric) && max_amount > 0
              key.failure('maximum withdrawal amount must be a positive number')
            end

            # Check if max is greater than min
            min_amount = value['min'] || 0
            key.failure('maximum withdrawal amount must be greater than minimum amount') if max_amount <= min_amount
          end

          # Validate cooldown hours
          if value['cooldown_hours'].present?
            cooldown = value['cooldown_hours']
            key.failure('cooldown hours must be a non-negative number') unless cooldown.is_a?(Numeric) && cooldown >= 0
          end

          # Validate fee percentage (if applicable)
          if value['fee_percentage'].present?
            fee = value['fee_percentage']
            key.failure('fee percentage must be between 0 and 100') unless fee.is_a?(Numeric) && fee >= 0 && fee <= 100
          end
        end
      end
    end
  end
end

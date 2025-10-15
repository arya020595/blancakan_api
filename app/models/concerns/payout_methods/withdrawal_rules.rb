# frozen_string_literal: true

module PayoutMethods
  module WithdrawalRules
    extend ActiveSupport::Concern

    included do
      # Field definition (if not already defined in the model)
      field :withdrawal_rules, type: Hash, default: {} unless fields.key?('withdrawal_rules')
      
      # Validations
      validates :withdrawal_rules, presence: true
      validate :valid_withdrawal_rules
    end

    # Instance methods for withdrawal rules
    def minimum_withdrawal_amount
      withdrawal_rules.dig('min') || 0
    end

    def maximum_withdrawal_amount
      withdrawal_rules.dig('max')
    end

    def withdrawal_cooldown_hours
      withdrawal_rules.dig('cooldown_hours') || 0
    end

    def withdrawal_fee_percentage
      withdrawal_rules.dig('fee_percentage') || 0
    end

    def can_withdraw?(amount)
      return false if amount < minimum_withdrawal_amount
      return false if maximum_withdrawal_amount.present? && amount > maximum_withdrawal_amount
      
      true
    end

    def withdrawal_fee_for(amount)
      return 0 if withdrawal_fee_percentage == 0
      
      (amount * withdrawal_fee_percentage / 100).round(2)
    end

    def net_withdrawal_amount(amount)
      amount - withdrawal_fee_for(amount)
    end

    def update_withdrawal_rules(new_rules)
      self.withdrawal_rules = withdrawal_rules.merge(new_rules.stringify_keys)
    end

    def reset_withdrawal_rules
      self.withdrawal_rules = {}
    end

    private

    def valid_withdrawal_rules
      return if withdrawal_rules.blank?

      validate_minimum_amount
      validate_maximum_amount
      validate_cooldown_hours
      validate_fee_percentage
      validate_min_max_relationship
    end

    def validate_minimum_amount
      return unless withdrawal_rules['min'].present?

      min_amount = withdrawal_rules['min']
      unless min_amount.is_a?(Numeric) && min_amount >= 0
        errors.add(:withdrawal_rules, 'minimum amount must be a non-negative number')
      end
    end

    def validate_maximum_amount
      return unless withdrawal_rules['max'].present?

      max_amount = withdrawal_rules['max']
      unless max_amount.is_a?(Numeric) && max_amount > 0
        errors.add(:withdrawal_rules, 'maximum amount must be a positive number')
      end
    end

    def validate_cooldown_hours
      return unless withdrawal_rules['cooldown_hours'].present?

      cooldown = withdrawal_rules['cooldown_hours']
      unless cooldown.is_a?(Numeric) && cooldown >= 0
        errors.add(:withdrawal_rules, 'cooldown hours must be a non-negative number')
      end
    end

    def validate_fee_percentage
      return unless withdrawal_rules['fee_percentage'].present?

      fee = withdrawal_rules['fee_percentage']
      unless fee.is_a?(Numeric) && fee >= 0 && fee <= 100
        errors.add(:withdrawal_rules, 'fee percentage must be between 0 and 100')
      end
    end

    def validate_min_max_relationship
      return unless withdrawal_rules['min'].present? && withdrawal_rules['max'].present?

      min_amount = withdrawal_rules['min']
      max_amount = withdrawal_rules['max']
      
      return unless min_amount.is_a?(Numeric) && max_amount.is_a?(Numeric)
      return unless max_amount <= min_amount

      errors.add(:withdrawal_rules, 'maximum amount must be greater than minimum amount')
    end
  end
end

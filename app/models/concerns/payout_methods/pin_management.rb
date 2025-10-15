# frozen_string_literal: true

module PayoutMethods
  module PinManagement
    extend ActiveSupport::Concern

    included do
      # Validates that pin_hash is present
      validates :pin_hash, presence: true
    end

    # Instance methods for PIN management
    def set_pin(plain_pin)
      self.pin_hash = BCrypt::Password.create(plain_pin)
    end

    def verify_pin(plain_pin)
      return false if pin_hash.blank? || plain_pin.blank?
      
      BCrypt::Password.new(pin_hash) == plain_pin
    rescue BCrypt::Errors::InvalidHash
      false
    end

    def pin_set?
      pin_hash.present?
    end

    def clear_pin!
      update!(pin_hash: nil)
    end
  end
end

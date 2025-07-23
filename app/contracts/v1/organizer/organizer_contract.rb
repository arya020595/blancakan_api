# frozen_string_literal: true

module V1
  module Organizer
    class OrganizerContract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        required(:description).filled(:string)
        required(:handle).filled(:string)
        required(:contact_phone).filled(:string)
        required(:user_id).filled(:string)
        optional(:avatar).maybe(:string)
        optional(:is_active).maybe(:bool)
      end

      rule(:handle) do
        unless value =~ /\A@[a-zA-Z0-9_]+\z/
          key.failure('must start with @ and contain only letters, numbers, and underscores')
        end
      end

      rule(:contact_phone) do
        # Accept various phone formats: 555-123-4567, (555) 123-4567, +1-555-123-4567, etc.
        phone_regex = /\A(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\z/
        key.failure('must be a valid phone number') unless value =~ phone_regex
      end

      rule(:user_id) do
        key.failure('user must exist') unless User.find(value)
      rescue StandardError
        false
      end
    end
  end
end

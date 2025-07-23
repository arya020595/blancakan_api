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
        optional(:avatar).maybe(:any) # Allow both string (base64) and file uploads
        optional(:is_active).maybe(:bool)
      end

      rule(:handle) do
        unless value =~ /\A@[a-zA-Z0-9_]+\z/
          key.failure('must start with @ and contain only letters, numbers, and underscores')
        end
      end

      rule(:contact_phone) do
        # Use same validation as model: /\A\+?[1-9]\d{1,14}\z/
        # Accepts: +1234567890, 1234567890 (1-15 digits total, first digit 1-9)
        phone_regex = /\A\+?[1-9]\d{1,14}\z/
        key.failure('must be a valid phone number') unless value =~ phone_regex
      end

      rule(:user_id) do
        key.failure('user must exist') unless User.find(value)
      rescue StandardError
        false
      end

      rule(:avatar) do
        if key? && value
          # Accept either a string (base64) or uploaded file
          is_string = value.is_a?(String)
          is_uploaded_file = defined?(ActionDispatch::Http::UploadedFile) && value.is_a?(ActionDispatch::Http::UploadedFile)

          key.failure('must be a string or uploaded file') unless is_string || is_uploaded_file
        end
      end
    end
  end
end

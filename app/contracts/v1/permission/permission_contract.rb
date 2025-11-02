# frozen_string_literal: true

module V1
  module Permission
    class PermissionContract < Dry::Validation::Contract
      params do
        required(:action).filled(:string)
        required(:subject_class).filled(:string)
        optional(:conditions).maybe(:any)
        required(:role_id).filled(:string)
      end

      rule(:role_id) do
        # Validate that role exists
        unless Role.where(id: value).exists?
          key.failure('role not found')
        end
      end

      rule(:conditions) do
        # Validate conditions is a hash or valid JSON
        next if value.blank?
        next if value.is_a?(Hash)
        
        # If it's a string, try to parse as JSON
        if value.is_a?(String)
          begin
            parsed = JSON.parse(value)
            key.failure('must be a valid JSON object') unless parsed.is_a?(Hash)
          rescue JSON::ParserError => e
            key.failure("must be valid JSON format: #{e.message}")
          end
        else
          key.failure('must be a hash or valid JSON string')
        end
      end
    end
  end
end

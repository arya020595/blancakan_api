# frozen_string_literal: true

module V1
  module Permission
    class PermissionContract < Dry::Validation::Contract
      params do
        required(:action).filled(:string)
        required(:subject_class).filled(:string)
        optional(:conditions).maybe(:hash)
        required(:role_id).filled(:string)
      end

      rule(:role_id) do
        # Validate that role exists
        unless Role.where(id: value).exists?
          key.failure('role not found')
        end
      end
    end
  end
end

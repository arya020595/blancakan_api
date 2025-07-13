# frozen_string_literal: true

module V1
  module Role
    class RoleContract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
      end
    end
  end
end

# frozen_string_literal: true

require 'dry/validation'

module V1
  module Category
    class CategoryContract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        optional(:is_active).maybe(:bool)
        optional(:parent_id).maybe(:string)
      end

      rule(:name) do
        key.failure('must be at least 3 characters') if value.length < 3
        key.failure('must be at most 100 characters') if value.length > 100
      end

      rule(:description) do
        key.failure('must be at most 255 characters') if key? && value && value.length > 255
      end
    end
  end
end

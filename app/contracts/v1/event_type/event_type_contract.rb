# frozen_string_literal: true

module V1
  module EventType
    class EventTypeContract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        optional(:slug).maybe(:string)
        optional(:icon_url).maybe(:string)
        optional(:description).maybe(:string)
        optional(:is_active).maybe(:bool)
        optional(:sort_order).maybe(:integer)
      end

      rule(:sort_order) do
        key.failure('must be greater than or equal to 0') if value && value < 0
      end
    end
  end
end

# frozen_string_literal: true

module V1
  module TicketType
    class TicketTypeContract < Dry::Validation::Contract
      params do
        required(:event_id).filled(:string)
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        required(:price).filled(:integer, gteq?: 0)
        required(:quota).filled(:integer, gteq?: 0)
        required(:available_from).filled(:date_time)
        required(:available_until).filled(:date_time)
        required(:valid_on).filled(:date_time)
        optional(:is_active).maybe(:bool?)
        optional(:sort_order).maybe(:integer, gteq?: 0)
        optional(:metadata).maybe(:string)
      end

      rule(:available_until, :available_from) do
        if values[:available_until] && values[:available_from] && values[:available_until] < (values[:available_from])
          key(:available_until).failure('must be after available_from')
        end
      end

      rule(:price) do
        key.failure('must be greater than or equal to 0') if value && value < 0
      end

      rule(:quota) do
        key.failure('must be greater than or equal to 0') if value && value < 0
      end
    end
  end
end

# frozen_string_literal: true

module V1
  module Permission
    class Contract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        required(:action).filled(:string)
        required(:subject).filled(:string)
      end
    end
  end
end

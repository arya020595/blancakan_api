# frozen_string_literal: true

module V1
  module PayoutMethod
    class PayoutMethodForm < ApplicationForm
      def call(attributes)
        contract = PayoutMethodContract.new
        result = contract.call(attributes)

        if result.success?
          Success(result.to_h)
        else
          Failure(result.errors.to_h)
        end
      end
    end
  end
end

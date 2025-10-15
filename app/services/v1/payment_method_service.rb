# frozen_string_literal: true

module V1
  # Service class for managing payment methods
  class PaymentMethodService
    include Dry::Monads[:result]

    def index(params = {})
      payment_methods = ::PaymentMethod.mongodb_search_with_filters(params)

      Success(payment_methods)
    end

    def show(payment_method)
      return Failure(nil) unless payment_method

      Success(payment_method)
    end

    def create(params)
      form = ::V1::PaymentMethod::PaymentMethodForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      payment_method = ::PaymentMethod.new(form.attributes)
      if payment_method.save
        Success(payment_method)
      else
        Failure(payment_method.errors.full_messages)
      end
    end

    def update(payment_method, params)
      form = ::V1::PaymentMethod::PaymentMethodForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if payment_method.update(form.attributes)
        Success(payment_method)
      else
        Failure(payment_method.errors.full_messages)
      end
    end

    def destroy(payment_method)
      return Failure(nil) unless payment_method

      if payment_method.destroy
        Success(payment_method)
      else
        Failure(payment_method.errors.full_messages)
      end
    end
  end
end

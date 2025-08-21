# frozen_string_literal: true

module V1
  class PayoutMethodService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      payout_methods = ::PayoutMethod.search(query: query, page: page, per_page: per_page)
      Success(payout_methods)
    end

    def show(payout_method)
      return Failure(nil) unless payout_method

      Success(payout_method)
    end

    def create(params)
      form = ::V1::PayoutMethod::PayoutMethodForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      # Find user if user_id provided (for admin)
      user = User.find(params[:user_id]) if params[:user_id].present?

      # Deactivate existing active payout method for the user
      PayoutMethod.deactivate_all_for_user(user) if user

      payout_method = ::PayoutMethod.new(form.attributes.except(:pin))
      payout_method.user = user if user

      # Set PIN if provided
      payout_method.set_pin(form.attributes[:pin]) if form.attributes[:pin].present?

      if payout_method.save
        Success(payout_method)
      else
        Failure(payout_method.errors.full_messages)
      end
    end

    def update(payout_method, params)
      form = ::V1::PayoutMethod::PayoutMethodForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      # Update PIN if provided
      payout_method.set_pin(form.attributes[:pin]) if form.attributes[:pin].present?

      if payout_method.update(form.attributes.except(:pin))
        Success(payout_method)
      else
        Failure(payout_method.errors.full_messages)
      end
    end

    def destroy(payout_method)
      return Failure(nil) unless payout_method

      if payout_method.destroy
        Success(payout_method)
      else
        Failure(payout_method.errors.full_messages)
      end
    end

    def activate(payout_method)
      return Failure(nil) unless payout_method

      if payout_method.activate!
        Success(payout_method)
      else
        Failure(payout_method.errors.full_messages)
      end
    end

    def deactivate(payout_method)
      return Failure(nil) unless payout_method

      if payout_method.deactivate!
        Success(payout_method)
      else
        Failure(payout_method.errors.full_messages)
      end
    end

    def verify_pin(payout_method, pin)
      return Failure(nil) unless payout_method

      verified = payout_method.verify_pin(pin)
      Success({ verified: verified })
    rescue StandardError => e
      Failure({ error: e.message })
    end

    def active_method
      payout_method = PayoutMethod.active.first
      if payout_method
        Success(payout_method)
      else
        Failure({ error: 'No active payout method found' })
      end
    end
  end
end

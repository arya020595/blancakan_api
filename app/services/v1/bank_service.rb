# frozen_string_literal: true

module V1
  # Service class for managing banks
  class BankService
    include Dry::Monads[:result]

    def index(params = {}, scope)
      # Scope is required - always pass @banks from controller
      banks = scope.mongodb_search_with_filters(params)

      Success(banks)
    end

    def show(bank)
      return Failure(nil) unless bank

      Success(bank)
    end

    def create(params)
      form = ::V1::Bank::BankForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      bank = ::Bank.new(form.attributes)
      if bank.save
        Success(bank)
      else
        Failure(bank.errors.full_messages)
      end
    end

    def update(bank, params)
      form = ::V1::Bank::BankForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if bank.update(form.attributes)
        Success(bank)
      else
        Failure(bank.errors.full_messages)
      end
    end

    def destroy(bank)
      return Failure(nil) unless bank

      if bank.destroy
        Success(bank)
      else
        Failure(bank.errors.full_messages)
      end
    end

    def activate(bank)
      return Failure(nil) unless bank

      if bank.activate!
        Success(bank)
      else
        Failure(bank.errors.full_messages)
      end
    end

    def deactivate(bank)
      return Failure(nil) unless bank

      if bank.deactivate!
        Success(bank)
      else
        Failure(bank.errors.full_messages)
      end
    end

    def available_for_selection
      banks = ::Bank.available_for_selection
      Success(banks)
    end
  end
end

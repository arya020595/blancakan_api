# frozen_string_literal: true

module V1
  # Service class for managing users
  class UserService
    include Dry::Monads[:result]

    def index(params = {})
      users = ::User.search_with_filters(params)

      Success(users)
    end

    def show(user)
      return Failure(nil) unless user

      Success(user)
    end

    def create(params)
      form = ::V1::User::UserForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      user = ::User.new(form.attributes)
      if user.save
        Success(user)
      else
        Failure(user.errors.full_messages)
      end
    end

    def update(user, params)
      form = ::V1::User::UserForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if user.update(form.attributes)
        Success(user)
      else
        Failure(user.errors.full_messages)
      end
    end

    def destroy(user)
      return Failure(nil) unless user

      if user.destroy
        Success(user)
      else
        Failure(user.errors.full_messages)
      end
    end
  end
end

# frozen_string_literal: true

module V1
  # Service class for managing users
  class UserService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      users = ::User.search(query: query, page: page, per_page: per_page)
      Success(users)
    end

    def show(user)
      return Failure('User not found') unless user

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
      return Failure('User not found') unless user

      if user.destroy
        Success('User deleted')
      else
        Failure(user.errors.full_messages)
      end
    end
  end
end

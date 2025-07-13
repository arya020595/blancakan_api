# frozen_string_literal: true

module V1
  # Service class for managing users
  class UserService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      users = User.search(query: query, page: page, per_page: per_page)
      Success(users)
    rescue StandardError => e
      Failure(e.message)
    end

    def show(user)
      return Failure('User not found') unless user

      Success(user)
    rescue StandardError => e
      Failure(e.message)
    end

    def create(params)
      user = User.new(params)
      if user.save
        Success(user)
      else
        Failure(user.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def update(user, params)
      if user.update(params)
        Success(user)
      else
        Failure(user.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def destroy(user)
      return Failure('User not found') unless user

      if user.destroy
        Success('User deleted')
      else
        Failure(user.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end
  end
end

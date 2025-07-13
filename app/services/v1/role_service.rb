# frozen_string_literal: true

module V1
  # Service class for managing roles
  class RoleService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      roles = Role.search(query: query, page: page, per_page: per_page)
      Success(roles)
    rescue StandardError => e
      Failure(e.message)
    end

    def show(role)
      return Failure('Role not found') unless role

      Success(role)
    rescue StandardError => e
      Failure(e.message)
    end

    def create(params)
      role = Role.new(params)
      if role.save
        Success(role)
      else
        Failure(role.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def update(role, params)
      if role.update(params)
        Success(role)
      else
        Failure(role.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def destroy(role)
      return Failure('Role not found') unless role

      if role.destroy
        Success('Role deleted')
      else
        Failure(role.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end
  end
end

# frozen_string_literal: true

module V1
  # Service class for managing roles
  class RoleService
    include Dry::Monads[:result]

    def index
      roles = Role.all
      Success(roles)
    rescue StandardError => e
      Failure(e.message)
    end

    def show(id)
      role = Role.find(id)
      if role
        Success(role)
      else
        Failure('Role not found')
      end
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

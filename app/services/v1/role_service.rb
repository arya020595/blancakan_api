# frozen_string_literal: true

module V1
  # Service class for managing roles
  class RoleService
    include Dry::Monads[:result]

    def index(params = {}, scope)
      # Scope is required - always pass @roles from controller
      roles = scope.mongodb_search_with_filters(params)

      Success(roles)
    end

    def show(role)
      return Failure(nil) unless role

      Success(role)
    end

    def create(params)
      form = ::V1::Role::RoleForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      role = ::Role.new(form.attributes)
      if role.save
        Success(role)
      else
        Failure(role.errors.full_messages)
      end
    end

    def update(role, params)
      form = ::V1::Role::RoleForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if role.update(form.attributes)
        Success(role)
      else
        Failure(role.errors.full_messages)
      end
    end

    def destroy(role)
      return Failure(nil) unless role

      if role.destroy
        Success(role)
      else
        Failure(role.errors.full_messages)
      end
    end
  end
end

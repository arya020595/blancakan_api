# frozen_string_literal: true

module V1
  # Service class for managing roles
  class RoleService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      roles = ::Role.search(query: query, page: page, per_page: per_page)
      Success(roles)
    end

    def show(role)
      return Failure('Role not found') unless role

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
      return Failure('Role not found') unless role

      if role.destroy
        Success('Role deleted')
      else
        Failure(role.errors.full_messages)
      end
    end
  end
end

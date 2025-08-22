# frozen_string_literal: true

module V1
  # Service class for managing permissions
  class PermissionService
    include Dry::Monads[:result]

    def index(params = {})
      permissions = ::Permission.search_with_filters(params)

      Success(permissions)
    end

    def show(permission)
      return Failure(nil) unless permission

      Success(permission)
    end

    def create(params)
      form = ::V1::Permission::PermissionForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      permission = ::Permission.new(form.attributes)
      if permission.save
        Success(permission)
      else
        Failure(permission.errors.full_messages)
      end
    end

    def update(permission, params)
      form = ::V1::Permission::PermissionForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if permission.update(form.attributes)
        Success(permission)
      else
        Failure(permission.errors.full_messages)
      end
    end

    def destroy(permission)
      return Failure(nil) unless permission

      if permission.destroy
        Success(permission)
      else
        Failure(permission.errors.full_messages)
      end
    end
  end
end

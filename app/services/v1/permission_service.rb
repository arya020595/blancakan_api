# frozen_string_literal: true

module V1
  # Service class for managing permissions
  class PermissionService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      permissions = Permission.search(query: query, page: page, per_page: per_page)
      Success(permissions)
    rescue StandardError => e
      Failure(e.message)
    end

    def show(id)
      permission = Permission.find(id)
      if permission
        Success(permission)
      else
        Failure('Permission not found')
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def create(params)
      permission = Permission.new(params)
      if permission.save
        Success(permission)
      else
        Failure(permission.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def update(permission, params)
      if permission.update(params)
        Success(permission)
      else
        Failure(permission.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def destroy(permission)
      if permission.destroy
        Success('Permission deleted')
      else
        Failure(permission.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end
  end
end

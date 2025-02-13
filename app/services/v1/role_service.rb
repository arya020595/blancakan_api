# frozen_string_literal: true
module V1
  # Service class for managing roles, providing methods to list, show, create, update, and delete roles.
  class RoleService
    include Dry::Monads[:result]

    # List all roles.
    def index
      roles = Role.all
      Success(roles)
    rescue StandardError => e
      Failure(e.message)
    end

    # Get a single role by ID.
    def show(id)
      role = Role.find(id)
      Success(role)
    rescue Mongoid::Errors::DocumentNotFound, ActiveRecord::RecordNotFound => e
      Failure(e.message)
    end

    # Create a new role using the provided parameters.
    def create(params)
      role = Role.new(params)
      if role.save
        Success(role)
      else
        Failure(role.errors.full_messages)
      end
    end

    # Update an existing role.
    # Note: Assumes the role has already been loaded (for example, via load_and_authorize_resource).
    def update(role, params)
      if role.update(params)
        Success(role)
      else
        Failure(role.errors.full_messages)
      end
    end

    # Delete a role.
    # Note: Again, this assumes the role has been loaded.
    def destroy(role)
      if role.destroy
        Success(nil)
      else
        Failure(role.errors.full_messages)
      end
    end
  end
end

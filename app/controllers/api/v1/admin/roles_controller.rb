class Api::V1::Admin::RolesController < ApplicationController
  load_and_authorize_resource

  def initialize
    super()
    @role_service = Container.resolve(:v1_role_service)
  end

  def index
    result = @role_service.index
    if result.success?
      render json: { status: 'success', message: 'List of roles', data: result.value! }
    else
      render json: { status: 'error', message: 'Failed to fetch roles', errors: result.failure },
             status: :unprocessable_entity
    end
  end

  def show
    result = @role_service.show(params[:id])
    if result.success?
      render json: { status: 'success', message: 'Role found', data: result.value! }
    else
      render json: { status: 'error', message: 'Role not found', errors: result.failure },
             status: :not_found
    end
  end

  def create
    result = @role_service.create(role_params)
    if result.success?
      render json: { status: 'success', message: 'Role created', data: result.value! },
             status: :created
    else
      render json: { status: 'error', message: 'Role creation failed', errors: result.failure },
             status: :unprocessable_entity
    end
  end

  def update
    result = @role_service.update(@role, role_params)
    if result.success?
      render json: { status: 'success', message: 'Role updated', data: result.value! }
    else
      render json: { status: 'error', message: 'Role update failed', errors: result.failure },
             status: :unprocessable_entity
    end
  end

  def destroy
    result = @role_service.destroy(@role)
    if result.success?
      render json: { status: 'success', message: 'Role deleted' }
    else
      render json: { status: 'error', message: 'Role deletion failed', errors: result.failure },
             status: :unprocessable_entity
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, :description)
  end
end

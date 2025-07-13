# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing roles in the admin namespace.
      class RolesController < Api::V1::Admin::BaseController
        def initialize
          super
          @role_service = Container.resolve('v1.role_service')
        end

        def index
          result = @role_service.index(query: params[:query], page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'roles', action: :index)
        end

        def show
          result = @role_service.show(params[:id])
          format_response(result: result, resource: 'roles', action: :show)
        end

        def create
          result = @role_service.create(role_params)
          format_response(result: result, resource: 'roles', action: :create)
        end

        def update
          result = @role_service.update(@role, role_params)
          format_response(result: result, resource: 'roles', action: :update)
        end

        def destroy
          result = @role_service.destroy(@role)
          format_response(result: result, resource: 'roles', action: :destroy)
        end

        private

        def role_params
          params.require(:role).permit(:name, :description)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing permissions in the admin namespace.
      class PermissionsController < ApplicationController
        load_and_authorize_resource
        include ServiceResponseFormatter

        def initialize
          super
          @permission_service = Container.resolve('v1.permission_service')
        end

        def index
          result = @permission_service.index(page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'permissions', action: :index)
        end

        def show
          result = @permission_service.show(params[:id])
          format_response(result: result, resource: 'permissions', action: :show)
        end

        def create
          result = @permission_service.create(permission_params)
          format_response(result: result, resource: 'permissions', action: :create)
        end

        def update
          result = @permission_service.update(@permission, permission_params)
          format_response(result: result, resource: 'permissions', action: :update)
        end

        def destroy
          result = @permission_service.destroy(@permission)
          format_response(result: result, resource: 'permissions', action: :destroy)
        end

        private

        def permission_params
          params.require(:permission).permit(:action, :subject_class, :conditions, :role_id)
        end
      end
    end
  end
end

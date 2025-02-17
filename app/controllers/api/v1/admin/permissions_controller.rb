# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing permissions in the admin namespace.
      class PermissionsController < ApplicationController
        load_and_authorize_resource

        def initialize
          super
          @permission_service = Container.resolve('v1.permission_service')
        end

        def index
          result = @permission_service.index
          if result.success?
            render json: { status: 'success', message: I18n.t('permissions.index.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('permissions.index.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def show
          result = @permission_service.show(params[:id])
          if result.success?
            render json: { status: 'success', message: I18n.t('permissions.show.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('permissions.show.error'), errors: result.failure },
                   status: :not_found
          end
        end

        def create
          result = @permission_service.create(permission_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('permissions.create.success'), data: result.value! },
                   status: :created
          else
            render json: { status: 'error', message: I18n.t('permissions.create.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def update
          result = @permission_service.update(@permission, permission_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('permissions.update.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('permissions.update.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def destroy
          result = @permission_service.destroy(@permission)
          if result.success?
            render json: { status: 'success', message: I18n.t('permissions.destroy.success') }
          else
            render json: { status: 'error', message: I18n.t('permissions.destroy.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        private

        def permission_params
          params.require(:permission).permit(:action, :subject_class, :conditions, :role_id)
        end
      end
    end
  end
end

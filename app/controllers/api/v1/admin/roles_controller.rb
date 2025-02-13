# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing roles in the admin namespace.
      # Provides actions to list, show, create, update, and destroy roles.
      class RolesController < ApplicationController
        def initialize
          super
          @role_service = Container.resolve(:v1_role_service)
        end

        def index
          result = @role_service.index
          if result.success?
            render json: { status: 'success', message: I18n.t('roles.index.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('roles.index.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def show
          result = @role_service.show(params[:id])
          if result.success?
            render json: { status: 'success', message: I18n.t('roles.show.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('roles.show.error'), errors: result.failure },
                   status: :not_found
          end
        end

        def create
          result = @role_service.create(role_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('roles.create.success'), data: result.value! },
                   status: :created
          else
            render json: { status: 'error', message: I18n.t('roles.create.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def update
          result = @role_service.update(@role, role_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('roles.update.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('roles.update.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def destroy
          result = @role_service.destroy(@role)
          if result.success?
            render json: { status: 'success', message: I18n.t('roles.destroy.success') }
          else
            render json: { status: 'error', message: I18n.t('roles.destroy.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        private

        def role_params
          params.require(:role).permit(:name, :description)
        end
      end
    end
  end
end

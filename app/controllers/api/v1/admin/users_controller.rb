# frozen_string_literal: true

module Api
  module V1
    module Admin
      # UsersController handles administrative actions for managing users.
      class UsersController < ApplicationController
        load_and_authorize_resource

        def initialize
          super
          @user_service = Container.resolve('v1.user_service')
        end

        def index
          result = @user_service.index
          if result.success?
            render json: { status: 'success', message: I18n.t('users.index.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('users.index.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def show
          result = @user_service.show(params[:id])
          if result.success?
            render json: { status: 'success', message: I18n.t('users.show.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('users.show.error'), errors: result.failure },
                   status: :not_found
          end
        end

        def create
          result = @user_service.create(user_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('users.create.success'), data: result.value! },
                   status: :created
          else
            render json: { status: 'error', message: I18n.t('users.create.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def update
          result = @user_service.update(@user, user_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('users.update.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('users.update.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def destroy
          result = @user_service.destroy(@user)
          if result.success?
            render json: { status: 'success', message: I18n.t('users.destroy.success') }
          else
            render json: { status: 'error', message: I18n.t('users.destroy.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.require(:user).permit(:email, :password, :password_confirmation, :role_id)
        end
      end
    end
  end
end

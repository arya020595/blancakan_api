# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing users in the admin namespace.
      class UsersController < Api::V1::Admin::BaseController
        def initialize
          super
          @user_service = Container.resolve('v1.user_service')
        end

        def index
          result = @user_service.index(query: params[:query], page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'users', action: :index)
        end

        def show
          result = @user_service.show(params[:id])
          format_response(result: result, resource: 'users', action: :show)
        end

        def create
          result = @user_service.create(user_params)
          format_response(result: result, resource: 'users', action: :create)
        end

        def update
          result = @user_service.update(@user, user_params)
          format_response(result: result, resource: 'users', action: :update)
        end

        def destroy
          result = @user_service.destroy(@user)
          format_response(result: result, resource: 'users', action: :destroy)
        end

        private

        def user_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation, :role_id)
        end
      end
    end
  end
end

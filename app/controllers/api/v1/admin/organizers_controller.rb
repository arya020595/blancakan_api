# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing organizers in the admin namespace.
      class OrganizersController < Api::V1::Admin::BaseController
        def initialize
          super
          @organizer_service = Container.resolve('v1.organizer_service')
        end

        def index
          result = @organizer_service.index(query: params[:query], page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'organizers', action: :index)
        end

        def show
          result = @organizer_service.show(@organizer)
          format_response(result: result, resource: 'organizers', action: :show)
        end

        def create
          result = @organizer_service.create(organizer_params)
          format_response(result: result, resource: 'organizers', action: :create)
        end

        def update
          result = @organizer_service.update(@organizer, organizer_params)
          format_response(result: result, resource: 'organizers', action: :update)
        end

        def destroy
          result = @organizer_service.destroy(@organizer)
          format_response(result: result, resource: 'organizers', action: :destroy)
        end

        private

        def organizer_params
          params.require(:organizer).permit(:name, :description, :handle, :contact_phone, :user_id, :avatar, :is_active)
        end
      end
    end
  end
end

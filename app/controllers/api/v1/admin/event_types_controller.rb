# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing event types in the admin namespace.
      class EventTypesController < Api::V1::Admin::BaseController
        def initialize
          super
          @event_type_service = Container.resolve('v1.event_type_service')
        end

        def index
          result = @event_type_service.index(query: params[:query], page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'event_types', action: :index)
        end

        def show
          result = @event_type_service.show(@event_type)
          format_response(result: result, resource: 'event_types', action: :show)
        end

        def create
          result = @event_type_service.create(event_type_params)
          format_response(result: result, resource: 'event_types', action: :create)
        end

        def update
          result = @event_type_service.update(@event_type, event_type_params)
          format_response(result: result, resource: 'event_types', action: :update)
        end

        def destroy
          result = @event_type_service.destroy(@event_type)
          format_response(result: result, resource: 'event_types', action: :destroy)
        end

        private

        def event_type_params
          params.require(:event_type).permit(:name, :slug, :icon_url, :description, :is_active, :sort_order)
        end
      end
    end
  end
end

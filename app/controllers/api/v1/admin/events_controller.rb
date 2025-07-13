# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing events in the admin namespace.
      class EventsController < Api::V1::Admin::BaseController
        def initialize
          super
          @event_service = Container.resolve('v1.event_service')
        end

        def index
          result = @event_service.index(query: params[:query], page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'events', action: :index)
        end

        def show
          result = @event_service.show(params[:id])
          format_response(result: result, resource: 'events', action: :show)
        end

        def create
          result = @event_service.create(event_params)
          format_response(result: result, resource: 'events', action: :create)
        end

        def update
          result = @event_service.update(@event, event_params)
          format_response(result: result, resource: 'events', action: :update)
        end

        def destroy
          result = @event_service.destroy(@event)
          format_response(result: result, resource: 'events', action: :destroy)
        end

        private

        def event_params
          params.require(:event).permit(
            :title,
            :description,
            :start_date,
            :start_time,
            :end_date,
            :end_time,
            :location_type,
            :timezone,
            :event_type_id,
            :organizer_id,
            :cover_image_url,
            :status,
            :is_paid,
            location: {},
            category_ids: []
          )
        end
      end
    end
  end
end

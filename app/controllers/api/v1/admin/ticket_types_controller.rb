# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing ticket types in the admin namespace.
      class TicketTypesController < Api::V1::Admin::BaseController
        def initialize
          super
          @ticket_type_service = Container.resolve('v1.ticket_type_service')
        end

        def index
          result = @ticket_type_service.index(@ticket_types, params)
          format_response(result: result, resource: 'ticket_types', action: :index)
        end

        def show
          result = @ticket_type_service.show(@ticket_type)
          format_response(result: result, resource: 'ticket_types', action: :show)
        end

        def create
          result = @ticket_type_service.create(ticket_type_params)
          format_response(result: result, resource: 'ticket_types', action: :create)
        end

        def update
          result = @ticket_type_service.update(@ticket_type, ticket_type_params)
          format_response(result: result, resource: 'ticket_types', action: :update)
        end

        def destroy
          result = @ticket_type_service.destroy(@ticket_type)
          format_response(result: result, resource: 'ticket_types', action: :destroy)
        end

        private

        def ticket_type_params
          params.require(:ticket_type).permit(:event_id, :name, :description, :price,
                                              :quota, :available_from, :available_until, :valid_on, :is_active, :sort_order, :metadata)
        end
      end
    end
  end
end

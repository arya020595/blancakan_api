# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing events in the admin namespace.
      class EventsController < ApplicationController
        load_and_authorize_resource

        def initialize
          super
          @event_service = Container.resolve('v1.event_service')
        end

        def index
          result = @event_service.index
          if result.success?
            render json: { status: 'success', message: I18n.t('events.index.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('events.index.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def show
          result = @event_service.show(params[:id])
          if result.success?
            render json: { status: 'success', message: I18n.t('events.show.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('events.show.error'), errors: result.failure },
                   status: :not_found
          end
        end

        def create
          result = @event_service.create(event_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('events.create.success'), data: result.value! },
                   status: :created
          else
            render json: { status: 'error', message: I18n.t('events.create.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def update
          event = Event.find_by(id: params[:id])
          if event.nil?
            render json: { status: 'error', message: I18n.t('events.show.error') }, status: :not_found
            return
          end

          result = @event_service.update(event, event_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('events.update.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('events.update.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def destroy
          event = Event.find_by(id: params[:id])
          if event.nil?
            render json: { status: 'error', message: I18n.t('events.show.error') }, status: :not_found
            return
          end

          result = @event_service.destroy(event)
          if result.success?
            render json: { status: 'success', message: I18n.t('events.destroy.success') }
          else
            render json: { status: 'error', message: I18n.t('events.destroy.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        private

        def event_params
          params.require(:event).permit(:name, :description, :date, :location)
        end
      end
    end
  end
end

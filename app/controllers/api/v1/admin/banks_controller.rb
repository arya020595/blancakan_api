# frozen_string_literal: true

module Api
  module V1
    module Admin
      class BanksController < Api::V1::Admin::BaseController
        def initialize
          super
          @bank_service = Container.resolve('v1.bank_service')
        end

        def index
          result = @bank_service.index(params)
          format_response(result: result, resource: 'banks', action: :index)
        end

        def show
          result = @bank_service.show(@bank)
          format_response(result: result, resource: 'banks', action: :show)
        end

        def create
          result = @bank_service.create(bank_params)
          format_response(result: result, resource: 'banks', action: :create)
        end

        def update
          result = @bank_service.update(@bank, bank_params)
          format_response(result: result, resource: 'banks', action: :update)
        end

        def destroy
          result = @bank_service.destroy(@bank)
          format_response(result: result, resource: 'banks', action: :destroy)
        end

        def activate
          result = @bank_service.activate(@bank)
          format_response(result: result, resource: 'banks', action: :activate)
        end

        def deactivate
          result = @bank_service.deactivate(@bank)
          format_response(result: result, resource: 'banks', action: :deactivate)
        end

        def available
          result = @bank_service.available_for_selection
          format_response(result: result, resource: 'banks', action: :available)
        end

        private

        def bank_params
          params.require(:bank).permit(:code, :name, :logo_url, :is_active)
        end
      end
    end
  end
end

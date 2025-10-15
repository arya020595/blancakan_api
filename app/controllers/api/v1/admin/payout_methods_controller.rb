# frozen_string_literal: true

module Api
  module V1
    module Admin
      class PayoutMethodsController < Api::V1::Admin::BaseController
        def initialize
          super
          @payout_method_service = Container.resolve('v1.payout_method_service')
        end

        def index
          result = @payout_method_service.index(query: params[:query], page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'payout_methods', action: :index)
        end

        def show
          result = @payout_method_service.show(@payout_method)
          format_response(result: result, resource: 'payout_methods', action: :show)
        end

        def create
          result = @payout_method_service.create(payout_method_params)
          format_response(result: result, resource: 'payout_methods', action: :create)
        end

        def update
          result = @payout_method_service.update(@payout_method, payout_method_params)
          format_response(result: result, resource: 'payout_methods', action: :update)
        end

        def destroy
          result = @payout_method_service.destroy(@payout_method)
          format_response(result: result, resource: 'payout_methods', action: :destroy)
        end

        def activate
          result = @payout_method_service.activate(@payout_method)
          format_response(result: result, resource: 'payout_methods', action: :activate)
        end

        def deactivate
          result = @payout_method_service.deactivate(@payout_method)
          format_response(result: result, resource: 'payout_methods', action: :deactivate)
        end

        def verify_pin
          result = @payout_method_service.verify_pin(@payout_method, params[:pin])
          format_response(result: result, resource: 'payout_methods', action: :verify_pin)
        end

        def active
          result = @payout_method_service.active_method
          format_response(result: result, resource: 'payout_methods', action: :active)
        end

        private

        def payout_method_params
          params.require(:payout_method).permit(
            :user_id,
            :bank_id,
            :bank_account_no,
            :account_holder,
            :pin,
            :is_active,
            withdrawal_rules: {}
          )
        end
      end
    end
  end
end

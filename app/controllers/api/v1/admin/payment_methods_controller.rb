# frozen_string_literal: true

module Api
  module V1
    module Admin
      class PaymentMethodsController < Api::V1::Admin::BaseController
        def initialize
          super
          @payment_method_service = Container.resolve('v1.payment_method_service')
        end

        def index
          result = @payment_method_service.index(query: params[:query], page: params[:page],
                                                 per_page: params[:per_page])
          format_response(result: result, resource: 'payment_methods', action: :index)
        end

        def show
          result = @payment_method_service.show(@payment_method)
          format_response(result: result, resource: 'payment_methods', action: :show)
        end

        def create
          result = @payment_method_service.create(payment_method_params)
          format_response(result: result, resource: 'payment_methods', action: :create)
        end

        def update
          result = @payment_method_service.update(@payment_method, payment_method_params)
          format_response(result: result, resource: 'payment_methods', action: :update)
        end

        def destroy
          result = @payment_method_service.destroy(@payment_method)
          format_response(result: result, resource: 'payment_methods', action: :destroy)
        end

        private

        def payment_method_params
          params.require(:payment_method).permit(:code, :display_name, :type, :payment_gateway, :enabled, :fee_flat,
                                                 :fee_percent, :icon_url, :sort_order, :description)
        end
      end
    end
  end
end

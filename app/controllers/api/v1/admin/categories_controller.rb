module Api
  module V1
    module Admin
      class CategoriesController < ApplicationController
        load_and_authorize_resource
        include ServiceResponseFormatter

        def initialize
          super
          @category_service = Container.resolve('v1.category_service')
        end

        def index
          result = @category_service.index
          format_response(result: result, resource: 'categories', action: :index)
        end

        def show
          result = @category_service.show(params[:id])
          format_response(result: result, resource: 'categories', action: :show)
        end

        def create
          result = @category_service.create(category_params)
          format_response(result: result, resource: 'categories', action: :create)
        end

        def update
          result = @category_service.update(@category, category_params)
          format_response(result: result, resource: 'categories', action: :update)
        end

        def destroy
          result = @category_service.destroy(@category)
          format_response(result: result, resource: 'categories', action: :destroy)
        end

        private

        def category_params
          params.require(:category).permit(:name, :description, :status, :parent_id)
        end
      end
    end
  end
end

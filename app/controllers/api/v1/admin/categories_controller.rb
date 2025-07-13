module Api
  module V1
    module Admin
      # Controller for managing categories in the admin namespace.
      # It uses a service object to handle the business logic and formats the response using a custom formatter.
      class CategoriesController < Api::V1::Admin::BaseController
        def initialize
          super
          @category_service = Container.resolve('v1.category_service')
        end

        def index
          result = @category_service.index(query: params[:query], page: params[:page], per_page: params[:per_page])
          format_response(result: result, resource: 'events', action: :index)
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
          params.require(:category).permit(:name, :description, :is_active, :parent_id)
        end
      end
    end
  end
end

module Api
  module V1
    module Admin
      class CategoriesController < ApplicationController
        load_and_authorize_resource

        def initialize
          super
          @category_service = Container.resolve('v1.category_service')
        end

        def index
          result = @category_service.index
          if result.success?
            render json: { status: 'success', message: I18n.t('categories.index.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('categories.index.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def show
          result = @category_service.show(params[:id])
          if result.success?
            render json: { status: 'success', message: I18n.t('categories.show.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('categories.show.error'), errors: result.failure },
                   status: :not_found
          end
        end

        def create
          result = @category_service.create(category_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('categories.create.success'), data: result.value! },
                   status: :created
          else
            render json: { status: 'error', message: I18n.t('categories.create.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def update
          result = @category_service.update(@category, category_params)
          if result.success?
            render json: { status: 'success', message: I18n.t('categories.update.success'), data: result.value! }
          else
            render json: { status: 'error', message: I18n.t('categories.update.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        def destroy
          result = @category_service.destroy(@category)
          if result.success?
            render json: { status: 'success', message: I18n.t('categories.destroy.success') }
          else
            render json: { status: 'error', message: I18n.t('categories.destroy.error'), errors: result.failure },
                   status: :unprocessable_entity
          end
        end

        private

        def category_params
          params.require(:category).permit(:name, :description, :status, :parent_id)
        end
      end
    end
  end
end

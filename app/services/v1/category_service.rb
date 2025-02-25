# frozen_string_literal: true

module V1
  # Service class for managing categories
  class CategoryService
    include Dry::Monads[:result]

    def index(page: 1, per_page: 10)
      categories = Category.page(page).per(per_page)
      Success(categories)
    rescue StandardError => e
      Failure(e.message)
    end

    def show(id)
      category = Category.find(id)
      if category
        Success(category)
      else
        Failure('Category not found')
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def create(params)
      category = Category.new(params)
      if category.save
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def update(category, params)
      if category.update(params)
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def destroy(category)
      if category.destroy
        Success('Category deleted')
      else
        Failure(category.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end
  end
end

# frozen_string_literal: true

module V1
  # Service class for managing categories
  class CategoryService
    include Dry::Monads[:result]

    def index(params = {})
      categories = ::Category.search_with_filters(params)

      Success(categories)
    end

    def show(category)
      return Failure(nil) unless category

      Success(category)
    end

    def create(params)
      form = ::V1::Category::CategoryForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      category = ::Category.new(form.attributes)
      if category.save
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    end

    def update(category, params)
      form = ::V1::Category::CategoryForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if category.update(form.attributes)
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    end

    def destroy(category)
      return Failure(nil) unless category

      if category.destroy
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    end
  end
end

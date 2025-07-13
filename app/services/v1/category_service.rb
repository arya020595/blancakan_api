# frozen_string_literal: true

module V1
  # Service class for managing categories
  class CategoryService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      categories = ::Category.search(query: query, page: page, per_page: per_page)
      Success(categories)
    rescue StandardError => e
      Failure(e.message)
    end

    def show(category)
      return Failure('Category not found') unless category

      Success(category)
    rescue StandardError => e
      Failure(e.message)
    end

    def create(params)
      form = ::V1::CategoryForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      category = ::Category.new(form.attributes)
      if category.save
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def update(category, params)
      form = ::V1::CategoryForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if category.update(form.attributes)
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def destroy(category)
      return Failure('Category not found') unless category

      if category.destroy
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end
  end
end

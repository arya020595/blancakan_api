# frozen_string_literal: true

module V1
  # Service class for managing categories
  class CategoryService
    include Dry::Monads[:result]

    def index(query: nil, page: nil, per_page: nil)
      search_query = query.presence || '*'
      search_page = (page.presence || 1).to_i
      search_per_page = (per_page.presence || 10).to_i

      categories = Category.search(
        query: search_query,
        page: search_page,
        per_page: search_per_page
      )
      Success(categories)
    rescue StandardError => e
      Rails.logger.error "CategoryService#index error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
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

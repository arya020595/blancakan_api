module V1
  # Service class for managing categories, providing methods to list, show, create, update, and delete categories.
  class CategoryService
    include Dry::Monads[:result]

    # List all categories.
    def index
      categories = Category.all
      Success(categories)
    rescue StandardError => e
      Failure(e.message)
    end

    # Get a single category by ID.
    def show(id)
      category = Category.find(id)
      Success(category)
    rescue Mongoid::Errors::DocumentNotFound, ActiveRecord::RecordNotFound => e
      Failure(e.message)
    end

    # Create a new category using the provided parameters.
    def create(params)
      category = Category.new(params)
      if category.save
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    end

    # Update an existing category.
    # Note: Assumes the category has already been loaded (for example, via load_and_authorize_resource).
    def update(category, params)
      if category.update(params)
        Success(category)
      else
        Failure(category.errors.full_messages)
      end
    end

    # Delete a category.
    # Note: Again, this assumes the category has been loaded.
    def destroy(category)
      if category.destroy
        Success(nil)
      else
        Failure(category.errors.full_messages)
      end
    end
  end
end

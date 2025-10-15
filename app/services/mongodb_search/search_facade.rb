# frozen_string_literal: true

module MongodbSearch
  # SearchFacade orchestrates MongoDB search operations
  # Follows Facade pattern - provides simple interface for complex search operations
  class SearchFacade
    def initialize(model_class)
      @model_class = model_class
      @query_builder = QueryBuilder.new(model_class)
      @filter_builder = FilterBuilder.new(model_class)
      @sort_builder = SortBuilder.new(model_class)
    end

    def execute(params = {})
      # Build query components
      query_conditions = @query_builder.build(params[:query])
      filter_conditions = @filter_builder.build(params[:filter])
      sort_criteria = @sort_builder.build(params[:sort])

      # Combine query and filter conditions
      combined_conditions = merge_conditions(query_conditions, filter_conditions)

      # Execute MongoDB query with pagination
      execute_search(combined_conditions, sort_criteria, params)
    end

    private

    attr_reader :model_class

    def merge_conditions(query_conditions, filter_conditions)
      return filter_conditions if query_conditions.empty?
      return query_conditions if filter_conditions.empty?

      # Combine both conditions with $and
      { '$and' => [query_conditions, filter_conditions] }
    end

    def execute_search(conditions, sort_criteria, params)
      # Start with base query
      query = @model_class.where(conditions)

      # Apply sorting
      query = query.order_by(sort_criteria)

      # Apply pagination
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      query.page(page).per(per_page)
    end
  end
end

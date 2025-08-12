# frozen_string_literal: true

module Elasticsearch
  # Facade pattern for Elasticsearch operations
  # This class follows the Single Responsibility Principle by delegating
  # specific responsibilities to specialized service classes
  class SearchFacade
    include Dry::Monads[:result]

    def initialize(model_class)
      @model_class = model_class
      @query_builder = QueryBuilder.new(model_class)
      @filter_builder = FilterBuilder.new(model_class)
      @sort_builder = SortBuilder.new(model_class)
    end

    def execute(params = {})
      # Process and normalize parameters
      processed_params = process_params(params)

      # Build search query with pagination at Elasticsearch level
      search_query = build_search_query_with_pagination(processed_params)

      response = @model_class.__elasticsearch__.search(search_query)

      # Create a custom pagination wrapper that's compatible with ServiceResponseFormatter
      create_paginated_response(response, processed_params)
    end

    private

    attr_reader :model_class, :query_builder, :filter_builder, :sort_builder

    def process_params(params)
      {
        query: normalize_query(params[:query]),
        filter: normalize_filters(params[:filter]),
        sort: normalize_sort(params[:sort]),
        page: normalize_page(params[:page]),
        per_page: normalize_per_page(params[:per_page])
      }
    end

    def normalize_query(query)
      return nil if query.blank?

      query.to_s.strip
    end

    def normalize_filters(filters)
      return {} if filters.blank?

      normalized = {}
      filters.each do |key, value|
        next if value.blank?

        normalized[key.to_s] = value
      end
      normalized
    end

    def normalize_sort(sort)
      return nil if sort.blank?

      sort.to_s.strip
    end

    def normalize_page(page)
      page = page.to_i
      page < 1 ? 1 : page
    end

    def normalize_per_page(per_page)
      per_page = per_page.to_i
      return 10 if per_page < 1 # default
      return 100 if per_page > 100 # max

      per_page
    end

    def build_search_query(params)
      {
        query: build_query_section(params),
        sort: sort_builder.build(params[:sort])
      }.compact
    end

    def build_search_query_with_pagination(params)
      query = build_search_query(params)

      # Add pagination at Elasticsearch level for better performance
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      query.merge({
                    from: (page - 1) * per_page,
                    size: per_page,
                    _source: elasticsearch_source_fields # Specify fields to return from ES
                  })
    end

    def elasticsearch_source_fields
      # Get fields from the model's Elasticsearch configuration
      # This makes the service reusable across different models
      fields = []

      # Add searchable fields (for text queries)
      if @model_class.respond_to?(:elasticsearch_searchable_fields)
        fields.concat(@model_class.elasticsearch_searchable_fields)
      end

      # Add sortable fields (for sorting and filtering)
      if @model_class.respond_to?(:elasticsearch_sortable_fields)
        fields.concat(@model_class.elasticsearch_sortable_fields)
      end

      # Add essential fields that should always be included
      essential_fields = %w[_id location cover_image cover_image_filename category_ids]
      fields.concat(essential_fields)

      # Remove duplicates and Elasticsearch-only fields like _score
      fields.uniq.reject { |field| field.start_with?('_') && field != '_id' }
    end

    def create_paginated_response(es_response, params)
      # Convert Elasticsearch results directly to hash objects (no database query)
      records = es_response.results.map do |result|
        # Convert ES result to a hash that looks like an ActiveRecord object
        source = result._source.to_hash
        source['_id'] = result._id
        ElasticsearchRecord.new(source)
      end

      # Create a Kaminari-compatible wrapper
      total_count = es_response.results.total
      page = params[:page] || 1
      per_page = params[:per_page] || 10

      PaginatedElasticsearchResults.new(records, page, per_page, total_count)
    end

    def build_query_section(params)
      query_part = query_builder.build(params[:query])
      filter_part = filter_builder.build(params[:filter])

      if query_part.present? && filter_part.present?
        {
          bool: {
            must: [query_part],
            filter: filter_part
          }
        }
      elsif filter_part.present?
        {
          bool: {
            filter: filter_part
          }
        }
      else
        query_part || { match_all: {} }
      end
    end
  end
end

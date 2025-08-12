# frozen_string_literal: true

module Elasticsearch
  # Builds Elasticsearch query DSL for text search
  # Single Responsibility: Handle text search query construction
  class QueryBuilder
    def initialize(model_class)
      @model_class = model_class
    end

    def build(query_string)
      return nil if query_string.blank?

      normalized_query = normalize_query(query_string)

      if wildcard_query?(normalized_query)
        build_wildcard_query(normalized_query)
      else
        build_multi_match_query(normalized_query)
      end
    end

    private

    attr_reader :model_class

    def normalize_query(query_string)
      query_string.to_s.strip
    end

    def wildcard_query?(query)
      query == '*' || query.blank?
    end

    def build_wildcard_query(_query)
      { match_all: {} }
    end

    def build_multi_match_query(query)
      {
        multi_match: {
          query: query,
          fields: searchable_fields,
          type: 'best_fields',
          fuzziness: 'AUTO',
          minimum_should_match: '75%'
        }
      }
    end

    def searchable_fields
      # Get searchable fields from model or defaults
      Configuration.searchable_fields_for(model_class)
    end
  end
end

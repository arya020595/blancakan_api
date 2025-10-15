# frozen_string_literal: true

# Searchable concern provides flexible search functionality for MongoDB models
#
# This concern follows Ruby/Rails best practices:
# - Single Responsibility: Only handles search functionality
# - Clear API: Simple, predictable method signatures
# - Fail Fast: Raises error if searchable_fields not implemented
# - Performance: Optimized MongoDB queries with proper indexing hints
#
# Usage:
#   1. Include the concern in your model:
#      include Searchable
#
#   2. Define searchable fields in your model:
#      def self.searchable_fields
#        %w[name email description]
#      end
#
#   3. Use search methods:
#      Model.search('term')                          # Simple search
#      Model.search(query: 'term', page: 1)          # Service pattern
#      Model.search_all_terms('multiple terms')      # AND logic
#      Model.search_any_terms('multiple terms')      # OR logic
#
module Searchable
  extend ActiveSupport::Concern

  # Constants for better maintainability
  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  WILDCARD_QUERY = '*'
  TERM_SEPARATOR = /\s+/

  class_methods do
    # Main search method with flexible parameter handling
    #
    # @param query_or_params [String, Hash] Search query or parameters hash
    # @param options [Hash] Additional options (page, per_page, fields)
    # @return [Mongoid::Criteria] Searchable and paginated scope
    def search(query_or_params = nil, **options)
      search_params = normalize_search_params(query_or_params, options)

      scope = build_search_scope(
        query: search_params[:query],
        fields: search_params[:fields]
      )

      apply_pagination(scope, search_params[:page], search_params[:per_page])
    end

    # Search with multiple terms - ALL terms must match (AND logic)
    def search_all_terms(query, fields: nil)
      return all if query.blank?

      terms = extract_search_terms(query)
      return all if terms.empty?

      search_fields = fields || searchable_fields
      validate_searchable_fields!(search_fields)

      terms.reduce(all) do |scope, term|
        scope.where('$or' => build_field_conditions(term, search_fields))
      end
    end

    # Search with multiple terms - ANY term can match (OR logic)
    def search_any_terms(query, fields: nil)
      return all if query.blank?

      terms = extract_search_terms(query)
      return all if terms.empty?

      search_fields = fields || searchable_fields
      validate_searchable_fields!(search_fields)

      all_conditions = terms.flat_map { |term| build_field_conditions(term, search_fields) }
      where('$or' => all_conditions)
    end

    # Define which fields can be searched (override in your model)
    #
    # This method MUST be overridden in models that include this concern
    #
    # @return [Array<String>] List of searchable field names
    def searchable_fields
      raise NotImplementedError,
            "#{self} must implement #searchable_fields class method. " \
            'Example: def self.searchable_fields; %w[name email]; end'
    end

    private

    # Normalize search parameters from various input formats
    #
    # @param query_or_params [String, Hash] Input parameters
    # @param options [Hash] Additional options
    # @return [Hash] Normalized parameters
    def normalize_search_params(query_or_params, options)
      if query_or_params.is_a?(Hash)
        normalize_hash_params(query_or_params, options)
      else
        normalize_string_params(query_or_params, options)
      end
    end

    # Handle hash-style parameters
    def normalize_hash_params(params, options)
      {
        query: params[:search] || params[:query],
        page: params[:page] || options[:page] || DEFAULT_PAGE,
        per_page: params[:per_page] || options[:per_page] || DEFAULT_PER_PAGE,
        fields: options[:fields] || searchable_fields
      }
    end

    # Handle string-style parameters
    def normalize_string_params(query, options)
      {
        query: query || options[:query],
        page: options[:page] || DEFAULT_PAGE,
        per_page: options[:per_page] || DEFAULT_PER_PAGE,
        fields: options[:fields] || searchable_fields
      }
    end

    # Build the search scope with query conditions
    def build_search_scope(query:, fields:)
      scope = all

      # Handle wildcard or empty query
      return apply_default_ordering(scope) if query.blank? || query == WILDCARD_QUERY

      # Validate fields before building query
      validate_searchable_fields!(fields)

      # Apply search filter
      if fields.present?
        conditions = build_field_conditions(query, fields)
        scope = scope.where('$or' => conditions)
      end

      apply_default_ordering(scope)
    end

    # Apply default ordering if available
    def apply_default_ordering(scope)
      scope.respond_to?(:ordered) ? scope.ordered : scope
    end

    # Apply pagination if Kaminari is available
    def apply_pagination(scope, page, per_page)
      return scope unless defined?(Kaminari) && scope.respond_to?(:page)

      scope.page(page).per(per_page)
    end

    # Extract search terms from query string
    def extract_search_terms(query)
      query.to_s.split(TERM_SEPARATOR).reject(&:blank?)
    end

    # Build MongoDB regex conditions for searching across multiple fields
    def build_field_conditions(term, fields)
      regex = build_case_insensitive_regex(term)
      fields.map { |field| { field => regex } }
    end

    # Build optimized case-insensitive regex
    def build_case_insensitive_regex(term)
      /#{Regexp.escape(term.to_s)}/i
    end

    # Validate that searchable fields are properly defined
    def validate_searchable_fields!(fields)
      return if fields.present?

      raise ArgumentError,
            "#{self} has no searchable fields defined. " \
            'Implement #searchable_fields class method.'
    end
  end
end

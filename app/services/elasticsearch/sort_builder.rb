# frozen_string_literal: true

module Elasticsearch
  # Builds Elasticsearch sort DSL for result ordering
  # Single Responsibility: Handle sort construction
  class SortBuilder
    def initialize(model_class)
      @model_class = model_class
    end

    def build(sort_param)
      return default_sort if sort_param.blank?

      sort_clauses = parse_sort_param(sort_param)
      return default_sort if sort_clauses.empty?

      sort_clauses
    end

    private

    attr_reader :model_class

    def parse_sort_param(sort_param)
      sort_clauses = []

      # Handle multiple sort fields separated by comma
      sort_fields = sort_param.to_s.split(',').map(&:strip)

      sort_fields.each do |sort_field|
        field, direction = parse_sort_field(sort_field)
        next unless valid_sort_field?(field)

        sort_clause = build_sort_clause(field, direction)
        sort_clauses << sort_clause if sort_clause
      end

      sort_clauses
    end

    def parse_sort_field(sort_field)
      parts = sort_field.split(':')
      field = parts[0]&.strip
      direction = parts[1]&.strip&.downcase || 'asc'

      [field, direction]
    end

    def valid_sort_field?(field)
      return false if field.blank?

      # Check if the model defines allowed sortable fields
      if model_class.respond_to?(:elasticsearch_sortable_fields)
        model_class.elasticsearch_sortable_fields.include?(field)
      else
        # Default allowed fields if model doesn't specify
        default_sortable_fields.include?(field)
      end
    end

    def default_sortable_fields
      %w[
        created_at updated_at published_at
        title name
        start_date end_date
        _score _id
      ]
    end

    def build_sort_clause(field, direction)
      normalized_direction = normalize_direction(direction)

      case field
      when '_score'
        { '_score' => { 'order' => normalized_direction } }
      when '_id'
        { '_id' => { 'order' => normalized_direction } }
      else
        build_field_sort(field, normalized_direction)
      end
    end

    def build_field_sort(field, direction)
      # For text fields that might have keyword subfields
      if text_field_with_keyword?(field)
        {
          "#{field}.keyword" => {
            'order' => direction,
            'missing' => '_last',
            'unmapped_type' => 'keyword'
          }
        }
      else
        # For date, boolean, and other non-text fields, use the field directly
        {
          field => {
            'order' => direction,
            'missing' => '_last'
          }
        }
      end
    end

    def text_field_with_keyword?(field)
      # Fields that are typically text fields but have keyword subfields for sorting
      text_fields_with_keywords = %w[title status location_type timezone]
      text_fields_with_keywords.include?(field)
    end

    def normalize_direction(direction)
      case direction.to_s.downcase
      when 'desc', 'descending', 'down'
        'desc'
      when 'asc', 'ascending', 'up'
        'asc'
      else
        'asc' # Default to ascending
      end
    end

    def default_sort
      [
        { 'created_at' => { 'order' => 'desc' } }
      ]
    end
  end
end

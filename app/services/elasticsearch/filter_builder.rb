# frozen_string_literal: true

module Elasticsearch
  # Builds Elasticsearch filter DSL for precise filtering
  # Single Responsibility: Handle filter construction
  class FilterBuilder
    def initialize(model_class)
      @model_class = model_class
    end

    def build(filters)
      return nil if filters.blank?

      filter_clauses = []

      filters.each do |field, value|
        next if value.blank?

        filter_clause = build_filter_clause(field, value)
        filter_clauses << filter_clause if filter_clause
      end

      return nil if filter_clauses.empty?

      filter_clauses.length == 1 ? filter_clauses.first : combine_filters(filter_clauses)
    end

    private

    attr_reader :model_class

    def build_filter_clause(field, value)
      normalized_field = normalize_field_name(field)

      case determine_filter_type(normalized_field, value)
      when :term
        build_term_filter(normalized_field, value)
      when :terms
        build_terms_filter(normalized_field, value)
      when :range
        build_range_filter(normalized_field, value)
      when :bool
        build_bool_filter(normalized_field, value)
      when :exists
        build_exists_filter(normalized_field)
      else
        build_term_filter(normalized_field, value)
      end
    end

    def normalize_field_name(field)
      field.to_s
    end

    def determine_filter_type(field, value)
      return :exists if value == 'exists' || value == true && field.include?('exists')
      return :terms if value.is_a?(Array)
      if value.is_a?(Hash) && (value.key?('gte') || value.key?('lte') || value.key?('gt') || value.key?('lt'))
        return :range
      end
      return :bool if boolean_field?(field) || boolean_value?(value)

      :term
    end

    def boolean_field?(field)
      # Get boolean fields from model or defaults
      boolean_fields = Configuration.boolean_fields_for(model_class)
      boolean_fields.include?(field)
    end

    def boolean_value?(value)
      %w[true false].include?(value.to_s.downcase)
    end

    def build_term_filter(field, value)
      {
        term: {
          field => normalize_term_value(value)
        }
      }
    end

    def build_terms_filter(field, values)
      {
        terms: {
          field => values.map { |v| normalize_term_value(v) }
        }
      }
    end

    def build_range_filter(field, range_value)
      {
        range: {
          field => range_value
        }
      }
    end

    def build_bool_filter(field, value)
      {
        term: {
          field => normalize_boolean_value(value)
        }
      }
    end

    def build_exists_filter(field)
      {
        exists: {
          field: field
        }
      }
    end

    def normalize_term_value(value)
      return value.to_s.downcase if value.is_a?(String)

      value
    end

    def normalize_boolean_value(value)
      case value.to_s.downcase
      when 'true', '1', 'yes'
        true
      when 'false', '0', 'no'
        false
      else
        value
      end
    end

    def combine_filters(filter_clauses)
      {
        bool: {
          must: filter_clauses
        }
      }
    end
  end
end

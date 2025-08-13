# frozen_string_literal: true

module MongodbSearch
  # FilterBuilder handles filter construction for MongoDB queries
  # Follows Single Responsibility Principle - only builds filters
  class FilterBuilder
    def initialize(model_class)
      @model_class = model_class
    end

    def build(filter_params)
      return {} if filter_params.blank?

      conditions = {}
      filterable_fields = Configuration.filterable_fields_for(@model_class)
      boolean_fields = Configuration.boolean_fields_for(@model_class)

      filter_params.each do |field, value|
        field_str = field.to_s
        next unless filterable_fields.include?(field_str)

        conditions.merge!(build_field_filter(field_str, value, boolean_fields))
      end

      conditions
    end

    private

    attr_reader :model_class

    def build_field_filter(field, value, boolean_fields)
      return {} if value.nil?

      case value
      when Hash
        build_range_filter(field, value)
      when Array
        build_array_filter(field, value)
      when TrueClass, FalseClass
        build_boolean_filter(field, value, boolean_fields)
      else
        build_exact_filter(field, value)
      end
    end

    def build_range_filter(field, range_hash)
      conditions = {}

      # Handle date/numeric range filters
      range_hash.each do |operator, val|
        case operator.to_s
        when 'gte', 'gt', 'lte', 'lt'
          conditions[field] ||= {}
          conditions[field]["$#{operator}"] = parse_value(val)
        end
      end

      conditions
    end

    def build_array_filter(field, values)
      # Array means "any of these values" (OR logic)
      { field => { '$in' => values } }
    end

    def build_boolean_filter(field, value, boolean_fields)
      return {} unless boolean_fields.include?(field)

      { field => value }
    end

    def build_exact_filter(field, value)
      { field => value }
    end

    def parse_value(value)
      # Try to parse dates
      return Time.parse(value) if value.is_a?(String) && value.match?(/\d{4}-\d{2}-\d{2}/)

      value
    rescue ArgumentError
      value
    end
  end
end

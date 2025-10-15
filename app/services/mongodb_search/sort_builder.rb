# frozen_string_literal: true

module MongodbSearch
  # SortBuilder handles sort construction for MongoDB queries
  # Follows Single Responsibility Principle - only builds sort criteria
  class SortBuilder
    def initialize(model_class)
      @model_class = model_class
    end

    def build(sort_params)
      return Configuration.default_sort_for(@model_class) if sort_params.blank?

      case sort_params
      when String
        build_single_sort(sort_params)
      when Array
        build_multiple_sort(sort_params)
      else
        Configuration.default_sort_for(@model_class)
      end
    end

    private

    attr_reader :model_class

    def build_single_sort(sort_string)
      field, direction = parse_sort_string(sort_string)
      return Configuration.default_sort_for(@model_class) unless valid_sort_field?(field)

      { field => direction }
    end

    def build_multiple_sort(sort_array)
      sort_criteria = {}
      
      sort_array.each do |sort_string|
        field, direction = parse_sort_string(sort_string.to_s)
        next unless valid_sort_field?(field)
        
        sort_criteria[field] = direction
      end

      return Configuration.default_sort_for(@model_class) if sort_criteria.empty?
      sort_criteria
    end

    def parse_sort_string(sort_string)
      parts = sort_string.split(':')
      field = parts[0]
      direction = parts[1]&.downcase == 'asc' ? 1 : -1
      
      [field, direction]
    end

    def valid_sort_field?(field)
      sortable_fields = Configuration.sortable_fields_for(@model_class)
      sortable_fields.include?(field.to_s)
    end
  end
end

# frozen_string_literal: true

module MongodbSearch
  # Configuration class for MongoDB search defaults
  # This centralizes all default configurations in a clean, organized way
  class Configuration
    # Default field configurations - general fields that most models have
    DEFAULTS = {
      sortable_fields: %w[created_at updated_at _id],
      searchable_fields: %w[],  # Empty - models should define their own searchable fields
      text_fields: %w[],        # Fields with text indexes
      boolean_fields: [],
      filterable_fields: %w[created_at updated_at], # Fields that can be filtered
      default_sort: { created_at: -1 } # MongoDB sort format (1 = asc, -1 = desc)
    }.freeze

    class << self
      # Get default configuration value
      def get(key)
        DEFAULTS[key]
      end

      # Get sortable fields for a model
      def sortable_fields_for(model_class)
        if model_class.respond_to?(:mongodb_sortable_fields)
          model_class.mongodb_sortable_fields
        else
          get(:sortable_fields)
        end
      end

      # Get searchable fields for a model
      def searchable_fields_for(model_class)
        if model_class.respond_to?(:mongodb_searchable_fields)
          model_class.mongodb_searchable_fields
        else
          get(:searchable_fields)
        end
      end

      # Get text fields for a model
      def text_fields_for(model_class)
        if model_class.respond_to?(:mongodb_text_fields)
          model_class.mongodb_text_fields
        else
          get(:text_fields)
        end
      end

      # Get boolean fields for a model
      def boolean_fields_for(model_class)
        if model_class.respond_to?(:mongodb_boolean_fields)
          model_class.mongodb_boolean_fields
        else
          get(:boolean_fields)
        end
      end

      # Get filterable fields for a model
      def filterable_fields_for(model_class)
        if model_class.respond_to?(:mongodb_filterable_fields)
          model_class.mongodb_filterable_fields
        else
          get(:filterable_fields)
        end
      end

      # Get default sort for a model
      def default_sort_for(model_class)
        if model_class.respond_to?(:mongodb_default_sort)
          model_class.mongodb_default_sort
        else
          get(:default_sort)
        end
      end
    end
  end
end

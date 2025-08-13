# frozen_string_literal: true

module Elasticsearch
  # Configuration class for Elasticsearch defaults
  # This centralizes all default configurations in a clean, organized way
  class Configuration
    # Default field configurations
    DEFAULTS = {
      sortable_fields: %w[created_at updated_at published_at title name _score _id],
      searchable_fields: %w[title name description],
      text_fields_with_keywords: %w[title name status],
      boolean_fields: [],
      essential_fields: %w[_id],
      default_sort: [{ 'created_at' => { 'order' => 'desc' } }]
    }.freeze

    class << self
      # Get default configuration value
      def get(key)
        DEFAULTS[key]
      end

      # Get sortable fields for a model
      def sortable_fields_for(model_class)
        if model_class.respond_to?(:elasticsearch_sortable_fields)
          model_class.elasticsearch_sortable_fields
        else
          get(:sortable_fields)
        end
      end

      # Get searchable fields for a model
      def searchable_fields_for(model_class)
        if model_class.respond_to?(:elasticsearch_searchable_fields)
          model_class.elasticsearch_searchable_fields
        else
          get(:searchable_fields)
        end
      end

      # Get text fields with keywords for a model
      def text_fields_with_keywords_for(model_class)
        if model_class.respond_to?(:elasticsearch_text_fields_with_keywords)
          model_class.elasticsearch_text_fields_with_keywords
        else
          get(:text_fields_with_keywords)
        end
      end

      # Get boolean fields for a model
      def boolean_fields_for(model_class)
        if model_class.respond_to?(:elasticsearch_boolean_fields)
          model_class.elasticsearch_boolean_fields
        else
          get(:boolean_fields)
        end
      end

      # Get default sort for a model
      def default_sort_for(model_class)
        if model_class.respond_to?(:elasticsearch_default_sort)
          model_class.elasticsearch_default_sort
        else
          get(:default_sort)
        end
      end

      # Get essential fields for a model
      def essential_fields_for(model_class)
        if model_class.respond_to?(:elasticsearch_essential_fields)
          model_class.elasticsearch_essential_fields
        else
          get(:essential_fields)
        end
      end
    end
  end
end

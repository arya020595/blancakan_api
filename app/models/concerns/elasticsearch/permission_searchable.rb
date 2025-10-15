module Elasticsearch
  module PermissionSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    included do
      settings do
        mappings dynamic: false do
          indexes :action, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :subject_class, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :conditions, type: :object
          indexes :role_id, type: :keyword
          indexes :created_at, type: :date
          indexes :updated_at, type: :date
        end
      end

      def as_indexed_json(_options = {})
        as_json(only: %i[action subject_class conditions role_id created_at updated_at])
      end
    end

    module ClassMethods
      def elasticsearch_searchable_fields
        %w[action subject_class]
      end

      def elasticsearch_sortable_fields
        %w[action subject_class role_id created_at updated_at _score _id]
      end

      def elasticsearch_text_fields_with_keywords
        %w[action subject_class]
      end

      def elasticsearch_boolean_fields
        []
      end

      def elasticsearch_essential_fields
        %w[_id role_id]
      end
    end
  end
end

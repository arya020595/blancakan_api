module Elasticsearch
  module TicketTypeSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    included do
      settings do
        mappings dynamic: false do
          indexes :name, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :description, type: :text, analyzer: 'standard'
          indexes :price, type: :integer
          indexes :quota, type: :integer
          indexes :available_from, type: :date
          indexes :available_until, type: :date
          indexes :valid_on, type: :date
          indexes :is_active, type: :boolean
          indexes :sort_order, type: :integer
          indexes :metadata, type: :object, enabled: false
          indexes :event_id, type: :keyword
          indexes :created_at, type: :date
          indexes :updated_at, type: :date
        end
      end

      def as_indexed_json(_options = {})
        as_json(only: %i[name description price quota available_from available_until valid_on is_active sort_order
                         metadata event_id created_at updated_at])
      end
    end

    module ClassMethods
      def elasticsearch_searchable_fields
        %w[name description]
      end

      def elasticsearch_sortable_fields
        %w[name price quota available_from available_until valid_on is_active sort_order event_id created_at updated_at
           _score _id]
      end

      def elasticsearch_text_fields_with_keywords
        %w[name]
      end

      def elasticsearch_boolean_fields
        %w[is_active]
      end

      def elasticsearch_essential_fields
        %w[_id event_id]
      end
    end
  end
end

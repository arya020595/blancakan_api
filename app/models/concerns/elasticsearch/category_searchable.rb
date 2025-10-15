module Elasticsearch
  module CategorySearchable
    extend ActiveSupport::Concern
    # Include shared search functionality
    include BaseSearchable

    included do
      settings do
        mappings dynamic: false do
          indexes :name, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :description, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :is_active, type: :boolean
          indexes :parent_id, type: :keyword
          indexes :created_at, type: :date
          indexes :updated_at, type: :date
        end
      end

      def as_indexed_json(_options = {})
        as_json(only: %i[name description is_active parent_id created_at updated_at])
      end
    end

    module ClassMethods
      def search(query: '*', page: 1, per_page: 10)
        search_definition = if query == '*' || query.nil?
                              { query: { match_all: {} } }
                            else
                              { query: { multi_match: { query: query,
                                                        fields: %w[name description] } } }
                            end

        begin
          response = __elasticsearch__.search(search_definition)
          response.records.page(page).per(per_page)
        rescue StandardError => e
          HelperLogger.error(
            "Elasticsearch search failed: #{e.message}",
            klass: name,
            extra: { error: e.class.name, backtrace: e.backtrace }
          )
          # Fallback to database with same interface
          Category.page(page).per(per_page)
        end
      end

      # Fields that can be searched with text queries
      def elasticsearch_searchable_fields
        %w[name description]
      end

      # Fields that can be used for sorting
      def elasticsearch_sortable_fields
        %w[name description is_active parent_id created_at updated_at _score _id]
      end

      # Fields that are text fields with keyword subfields for sorting
      def elasticsearch_text_fields_with_keywords
        %w[name description]
      end

      # Fields that are boolean type for filtering
      def elasticsearch_boolean_fields
        %w[is_active]
      end

      # Essential fields that should always be included in Elasticsearch source
      def elasticsearch_essential_fields
        %w[_id parent_id]
      end
    end
  end
end

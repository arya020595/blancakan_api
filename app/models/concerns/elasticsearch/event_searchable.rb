module Elasticsearch
  module EventSearchable
    extend ActiveSupport::Concern
    # Include shared search functionality
    include BaseSearchable

    included do
      # Elasticsearch index configuration
      settings do
        mappings dynamic: false do
          # Text fields for search with keyword subfields for sorting/filtering
          indexes :title, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :description, type: :text, analyzer: 'standard'

          # Keyword fields for exact matching and sorting
          indexes :slug, type: :keyword
          indexes :short_id, type: :keyword
          indexes :status, type: :keyword
          indexes :location_type, type: :keyword, fields: {
            text: { type: :text, analyzer: 'standard' }
          }
          indexes :timezone, type: :keyword
          indexes :cover_image, type: :keyword
          indexes :organizer_id, type: :keyword
          indexes :event_type_id, type: :keyword
          indexes :category_ids, type: :keyword

          # Date fields for date filtering and sorting
          indexes :starts_at_local, type: :date
          indexes :starts_at_utc, type: :date
          indexes :ends_at_local, type: :date
          indexes :ends_at_utc, type: :date
          indexes :published_at, type: :date
          indexes :canceled_at, type: :date
          indexes :created_at, type: :date
          indexes :updated_at, type: :date

          # Boolean and object fields
          indexes :is_paid, type: :boolean
          indexes :location, type: :object, enabled: true
        end
      end

      # Define what data gets indexed for Elasticsearch
      def as_indexed_json(_options = {})
        attributes = as_json(only: %i[
                               title slug short_id description status location_type location
                               starts_at_local starts_at_utc ends_at_local ends_at_utc timezone is_paid published_at
                               canceled_at organizer_id event_type_id category_ids
                             ])

        # Add cover_image URL if present
        attributes[:cover_image] = cover_image&.url

        attributes
      end
    end

    # for Elasticsearch integration in the Event model.
    module ClassMethods
      # Original search method for backward compatibility
      def search(query: '*', page: 1, per_page: 10)
        search_definition = if query == '*' || query.nil?
                              { query: { match_all: {} } }
                            else
                              {
                                query: {
                                  multi_match: {
                                    query: query,
                                    fields: elasticsearch_searchable_fields,
                                    type: 'best_fields',
                                    fuzziness: 'AUTO'
                                  }
                                }
                              }
                            end

        response = __elasticsearch__.search(search_definition)
        response.records.page(page).per(per_page)
      end

      # Fields that can be searched with text queries
      def elasticsearch_searchable_fields
        %w[title description location_type status slug short_id]
      end

      # Fields that can be used for sorting
      def elasticsearch_sortable_fields
        %w[
          title status slug short_id location_type timezone is_paid
          starts_at_local starts_at_utc ends_at_local ends_at_utc organizer_id event_type_id
          created_at updated_at published_at canceled_at
          _score _id
        ]
      end

      # Fields that are text fields with keyword subfields for sorting
      def elasticsearch_text_fields_with_keywords
        %w[title status location_type timezone]
      end

      # Fields that are boolean type for filtering
      def elasticsearch_boolean_fields
        %w[is_paid]
      end

      # Essential fields that should always be included in Elasticsearch source
      def elasticsearch_essential_fields
        %w[_id location cover_image cover_image_filename category_ids]
      end
    end
  end
end

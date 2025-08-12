module Elasticsearch
  module EventSearchable
    extend ActiveSupport::Concern
    # Include shared search functionality
    include BaseSearchable

    included do
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks

      # Elasticsearch index configuration
      settings do
        mappings dynamic: false do
          # Text fields for search
          indexes :title, type: :text, analyzer: 'standard'
          indexes :description, type: :text, analyzer: 'standard'

          # Keyword fields for exact matching and sorting
          indexes :slug, type: :keyword
          indexes :short_id, type: :keyword
          indexes :status, type: :keyword
          indexes :location_type, type: :keyword
          indexes :timezone, type: :keyword
          indexes :cover_image, type: :keyword
          indexes :organizer_id, type: :keyword
          indexes :event_type_id, type: :keyword
          indexes :category_ids, type: :keyword

          # Date fields for date filtering and sorting
          indexes :start_date, type: :date
          indexes :end_date, type: :date
          indexes :start_time, type: :date
          indexes :end_time, type: :date
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
                               start_date start_time end_date end_time timezone is_paid published_at
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
          status slug short_id location_type timezone is_paid
          start_date end_date organizer_id event_type_id
          created_at updated_at published_at
          _score _id
        ]
      end
    end
  end
end

module Elasticsearch
  module EventSearchable
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks

      settings do
        mappings dynamic: false do
          indexes :title, type: :text, analyzer: 'standard'
          indexes :slug, type: :keyword
          indexes :short_id, type: :keyword
          indexes :description, type: :text, analyzer: 'standard'
          indexes :cover_image, type: :keyword
          indexes :status, type: :keyword
          indexes :location_type, type: :keyword
          indexes :location, type: :object, enabled: true
          indexes :start_date, type: :date
          indexes :start_time, type: :date
          indexes :end_date, type: :date
          indexes :end_time, type: :date
          indexes :timezone, type: :keyword
          indexes :is_paid, type: :boolean
          indexes :published_at, type: :date
          indexes :canceled_at, type: :date
          indexes :organizer_id, type: :keyword
          indexes :event_type_id, type: :keyword
          indexes :category_ids, type: :keyword
          # Add more fields as needed
        end
      end

      def as_indexed_json(_options = {})
        attributes = as_json(only: %i[
                               title slug short_id description status location_type location start_date start_time end_date end_time timezone is_paid published_at canceled_at organizer_id event_type_id category_ids
                             ])

        # Handle CarrierWave uploader for cover_image
        attributes[:cover_image] = cover_image.present? ? cover_image.url : nil

        attributes
      end
    end

    module ClassMethods
      def search(query: '*', page: 1, per_page: 10)
        search_definition = if query == '*' || query.nil?
                              { query: { match_all: {} } }
                            else
                              { query: { multi_match: { query: query,
                                                        fields: %w[title description location_type location status slug
                                                                   short_id] } } }
                            end

        response = __elasticsearch__.search(search_definition)
        response.records.page(page).per(per_page)
      end
    end
  end
end

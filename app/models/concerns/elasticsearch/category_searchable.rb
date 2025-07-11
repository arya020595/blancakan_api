module Elasticsearch
  module CategorySearchable
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks

      settings do
        mappings dynamic: false do
          indexes :name, type: :text, analyzer: 'standard'
          indexes :description, type: :text, analyzer: 'standard'
          indexes :is_active, type: :boolean
          indexes :parent_id, type: :keyword
        end
      end

      def as_indexed_json(_options = {})
        as_json(only: %i[name description is_active parent_id])
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
          Rails.logger.error "Elasticsearch search failed: #{e.message}"
          # Fallback to database with same interface
          Category.page(page).per(per_page)
        end
      end
    end
  end
end

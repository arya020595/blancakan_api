module Elasticsearch
  module PermissionSearchable
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks

      settings do
        mappings dynamic: false do
          indexes :action, type: :text, analyzer: 'standard'
          indexes :subject_class, type: :text, analyzer: 'standard'
          indexes :conditions, type: :object
        end
      end

      def as_indexed_json(_options = {})
        as_json(only: %i[action subject_class conditions])
      end
    end

    module ClassMethods
      def search(query: '*', page: 1, per_page: 10)
        search_definition = if query == '*' || query.nil?
                              { query: { match_all: {} } }
                            else
                              { query: { multi_match: { query: query,
                                                        fields: %w[action subject_class conditions] } } }
                            end

        response = __elasticsearch__.search(search_definition)
        response.records.page(page).per(per_page)
      end
    end
  end
end

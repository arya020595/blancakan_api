module Elasticsearch
  module UserSearchable
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks

      settings do
        mappings dynamic: false do
          indexes :email, type: :text, analyzer: 'standard'
          indexes :name, type: :text, analyzer: 'standard'
          indexes :provider, type: :keyword
          indexes :uid, type: :keyword
        end
      end

      def as_indexed_json(_options = {})
        as_json(only: %i[email name provider uid])
      end
    end

    module ClassMethods
      def search(query: '*', page: 1, per_page: 10)
        search_definition = if query == '*' || query.nil?
                              { query: { match_all: {} } }
                            else
                              { query: { multi_match: { query: query,
                                                        fields: %w[email name provider uid] } } }
                            end

        response = __elasticsearch__.search(search_definition)
        response.records.page(page).per(per_page)
      end
    end
  end
end

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings do
      mappings dynamic: false do
        indexes :title, type: :text, analyzer: 'standard'
        indexes :description, type: :text, analyzer: 'standard'
        indexes :location, type: :text, analyzer: 'standard'
        indexes :starts_at, type: :date
        indexes :ends_at, type: :date
        indexes :category_id, type: :keyword
        indexes :user_id, type: :keyword
        indexes :organizer, type: :text, analyzer: 'standard'
      end
    end

    def as_indexed_json(_options = {})
      as_json(only: %i[title description location starts_at ends_at category_id user_id organizer])
    end
  end

  module ClassMethods
    def search(query:, page:, per_page:)
      search_definition = if query == '*' || query.nil?
                            { query: { match_all: {} } }
                          else
                            { query: { multi_match: { query: query,
                                                      fields: %w[title description location organizer] } } }
                          end

      response = __elasticsearch__.search(search_definition)
      response.records.page(page).per(per_page)
    end
  end
end

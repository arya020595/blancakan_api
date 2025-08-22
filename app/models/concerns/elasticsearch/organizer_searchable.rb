module Elasticsearch
  module OrganizerSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    included do
      settings do
        mappings dynamic: false do
          indexes :handle, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :name, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :description, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :contact_phone, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :user_id, type: :keyword
          indexes :is_active, type: :boolean
          indexes :created_at, type: :date
          indexes :updated_at, type: :date
        end
      end

      def as_indexed_json(_options = {})
        as_json(only: %i[handle name description contact_phone user_id is_active created_at updated_at])
      end
    end

    module ClassMethods
      def search(query: '*', page: 1, per_page: 10)
        search_definition = if query == '*' || query.nil?
                              { query: { match_all: {} } }
                            else
                              { query: { multi_match: { query: query,
                                                        fields: %w[handle name description contact_phone] } } }
                            end

        response = __elasticsearch__.search(search_definition)
        response.records.page(page).per(per_page)
      end

      def elasticsearch_searchable_fields
        %w[handle name description contact_phone is_active]
      end

      def elasticsearch_sortable_fields
        %w[handle name contact_phone user_id created_at updated_at is_active _score _id]
      end

      def elasticsearch_text_fields_with_keywords
        %w[handle name description contact_phone]
      end

      def elasticsearch_boolean_fields
        %w[is_active]
      end

      def elasticsearch_essential_fields
        %w[_id user_id]
      end
    end
  end
end

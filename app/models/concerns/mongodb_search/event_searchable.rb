# frozen_string_literal: true

module MongodbSearch
  module EventSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    module ClassMethods
      # Fields that can be searched with text queries or regex
      def mongodb_searchable_fields
        %w[name description location]
      end

      # Fields that can be used for sorting
      def mongodb_sortable_fields
        %w[name description location starts_at_utc ends_at_utc is_active created_at updated_at _id]
      end

      # Fields that are text indexes (MongoDB $text search)
      def mongodb_text_fields
        %w[name description location]
      end

      # Fields that are boolean type for filtering
      def mongodb_boolean_fields
        %w[is_active is_featured]
      end

      # Fields that can be filtered
      def mongodb_filterable_fields
        %w[name description location is_active is_featured organizer_id event_type_id category_ids starts_at_utc
           ends_at_utc timezone created_at updated_at]
      end

      # Default sort order
      def mongodb_default_sort
        { starts_at_utc: -1, name: 1 } # Sort by start date (UTC) descending, then name
      end
    end
  end
end

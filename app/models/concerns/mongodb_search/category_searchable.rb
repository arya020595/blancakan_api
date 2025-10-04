# frozen_string_literal: true

module MongodbSearch
  module CategorySearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    module ClassMethods
      # Fields that can be searched with text queries or regex
      def mongodb_searchable_fields
        %w[name description]
      end

      # Fields that can be used for sorting
      def mongodb_sortable_fields
        %w[name description is_active parent_id created_at updated_at _id]
      end

      # Fields with text indexes (MongoDB $text search)
      def mongodb_text_fields
        %w[name description]
      end

      # Fields that are boolean type for filtering
      def mongodb_boolean_fields
        %w[is_active]
      end

      # Fields that can be filtered
      def mongodb_filterable_fields
        %w[name description is_active parent_id created_at updated_at]
      end

      # Default sort order
      def mongodb_default_sort
        { name: 1 } # Sort by name alphabetically
      end
    end
  end
end

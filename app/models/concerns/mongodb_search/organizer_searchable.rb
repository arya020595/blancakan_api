# frozen_string_literal: true

module MongodbSearch
  module OrganizerSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    module ClassMethods
      # Fields that can be searched with text queries or regex
      def mongodb_searchable_fields
        %w[name email company_name]
      end

      # Fields that can be used for sorting
      def mongodb_sortable_fields
        %w[name email company_name is_active created_at updated_at _id]
      end

      # Fields with text indexes (MongoDB $text search)
      def mongodb_text_fields
        %w[name email company_name]
      end

      # Fields that are boolean type for filtering
      def mongodb_boolean_fields
        %w[is_active is_verified]
      end

      # Fields that can be filtered
      def mongodb_filterable_fields
        %w[name email company_name is_active is_verified created_at updated_at]
      end

      # Default sort order
      def mongodb_default_sort
        { name: 1 } # Sort by name alphabetically
      end
    end
  end
end

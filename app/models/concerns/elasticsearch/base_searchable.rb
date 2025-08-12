# frozen_string_literal: true

module Elasticsearch
  module BaseSearchable
    extend ActiveSupport::Concern

    module ClassMethods
      # Main search method - follows Single Responsibility Principle
      def search_with_filters(params = {})
        ensure_index_ready
        Elasticsearch::SearchFacade.new(self).execute(params)
      end

      private

      # Ensure Elasticsearch index is ready for searching
      def ensure_index_ready
        return if index_ready?

        create_index_if_missing
        populate_empty_index
      end

      # Check if index exists and is ready
      def index_ready?
        __elasticsearch__.index_exists? && index_has_documents?
      end

      # Check if index has any documents
      def index_has_documents?
        count_response = __elasticsearch__.client.count(index: __elasticsearch__.index_name)

        (count_response['count']).positive?
      rescue StandardError => e
        Rails.logger.warn "Could not check Elasticsearch index document count: #{e.message}"
        false
      end

      # Create index if it doesn't exist
      def create_index_if_missing
        return if __elasticsearch__.index_exists?

        Rails.logger.info "Creating Elasticsearch index for #{name}..."
        __elasticsearch__.create_index!
        Rails.logger.info '✅ Index created successfully'
      rescue StandardError => e
        Rails.logger.warn "Could not create Elasticsearch index: #{e.message}"
      end

      # Populate index if it's empty but database has records
      def populate_empty_index
        return unless count.positive? && !index_has_documents?

        Rails.logger.info "Populating empty Elasticsearch index with #{count} #{name.downcase} records..."
        import(force: true, refresh: true)
        Rails.logger.info '✅ Index populated successfully'
      rescue StandardError => e
        Rails.logger.warn "Bulk import failed (#{e.message}), trying individual indexing..."
        # If bulk import fails, try individual indexing
        begin
          find_each(&:index_document)
          __elasticsearch__.refresh_index!
          Rails.logger.info '✅ Individual indexing completed'
        rescue StandardError => fallback_error
          Rails.logger.error "Could not index documents: #{fallback_error.message}"
        end
      end
    end
  end
end

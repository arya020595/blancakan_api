# frozen_string_literal: true

module Elasticsearch
  # Service responsible for managing Elasticsearch index lifecycle
  # Single Responsibility: Handle index creation, validation, and population
  class IndexManager
    def initialize(model_class)
      @model_class = model_class
    end

    # Main method to ensure index is ready for searching
    def ensure_ready
      return if index_ready?

      create_index_if_missing
      populate_empty_index
    end

    # Check if index exists and has documents
    def index_ready?
      index_exists? && index_has_documents?
    end

    # Check if index exists
    def index_exists?
      @model_class.__elasticsearch__.index_exists?
    rescue StandardError => e
      HelperLogger.warn(
        "Could not check if Elasticsearch index exists: #{e.message}",
        klass: self.class.name,
        extra: { model_class: @model_class.name, error: e.class.name, backtrace: e.backtrace }
      )
      false
    end

    # Check if index has any documents
    def index_has_documents?
      count_response = @model_class.__elasticsearch__.client.count(
        index: @model_class.__elasticsearch__.index_name
      )
      count_response['count'].positive?
    rescue StandardError => e
      HelperLogger.warn(
        "Could not check Elasticsearch index document count: #{e.message}",
        klass: self.class.name,
        extra: { model_class: @model_class.name, error: e.class.name, backtrace: e.backtrace }
      )
      false
    end

    # Create index if it doesn't exist
    def create_index_if_missing
      return if index_exists?

      HelperLogger.info(
        'Creating Elasticsearch index...',
        klass: self.class.name,
        extra: { model_class: @model_class.name }
      )
      @model_class.__elasticsearch__.create_index!
      HelperLogger.info(
        '✅ Index created successfully',
        klass: self.class.name,
        extra: { model_class: @model_class.name }
      )
    rescue StandardError => e
      HelperLogger.warn(
        "Could not create Elasticsearch index: #{e.message}",
        klass: self.class.name,
        extra: { model_class: @model_class.name, error: e.class.name, backtrace: e.backtrace }
      )
    end

    # Populate index if it's empty but database has records
    def populate_empty_index
      return unless database_has_records? && !index_has_documents?

      HelperLogger.info(
        'Populating empty Elasticsearch index...',
        klass: self.class.name,
        extra: { model_class: @model_class.name, record_count: @model_class.count }
      )
      bulk_import_records
    rescue StandardError => e
      HelperLogger.warn(
        "Bulk import failed (#{e.message}), trying individual indexing...",
        klass: self.class.name,
        extra: { model_class: @model_class.name, error: e.class.name, backtrace: e.backtrace }
      )
      individual_import_records
    end

    # Force reindex all records (useful for maintenance)
    def reindex_all(force: false)
      if force || index_exists?
        HelperLogger.info(
          'Reindexing all records...',
          klass: self.class.name,
          extra: { model_class: @model_class.name }
        )
        @model_class.import(force: true, refresh: true)
        HelperLogger.info(
          '✅ Reindexing completed',
          klass: self.class.name,
          extra: { model_class: @model_class.name }
        )
      else
        HelperLogger.warn(
          'Index does not exist. Create it first.',
          klass: self.class.name,
          extra: { model_class: @model_class.name }
        )
      end
    end

    # Get index statistics
    def index_stats
      return {} unless index_exists?

      {
        exists: true,
        document_count: document_count,
        database_count: @model_class.count,
        in_sync: document_count == @model_class.count
      }
    rescue StandardError => e
      HelperLogger.warn(
        "Could not get index stats: #{e.message}",
        klass: self.class.name,
        extra: { model_class: @model_class.name, error: e.class.name, backtrace: e.backtrace }
      )
      { exists: false, error: e.message }
    end

    private

    attr_reader :model_class

    def database_has_records?
      @model_class.count.positive?
    rescue StandardError => e
      HelperLogger.warn(
        "Could not check database record count: #{e.message}",
        klass: self.class.name,
        extra: { model_class: @model_class.name, error: e.class.name, backtrace: e.backtrace }
      )
      false
    end

    def document_count
      count_response = @model_class.__elasticsearch__.client.count(
        index: @model_class.__elasticsearch__.index_name
      )
      count_response['count']
    rescue StandardError
      0
    end

    def bulk_import_records
      @model_class.import(force: true, refresh: true)
      HelperLogger.info(
        '✅ Index populated successfully',
        klass: self.class.name,
        extra: { model_class: @model_class.name }
      )
    end

    def individual_import_records
      @model_class.find_each(&:index_document)
      @model_class.__elasticsearch__.refresh_index!
      HelperLogger.info(
        '✅ Individual indexing completed',
        klass: self.class.name,
        extra: { model_class: @model_class.name }
      )
    rescue StandardError => e
      HelperLogger.error(
        "Could not index documents: #{e.message}",
        klass: self.class.name,
        extra: { model_class: @model_class.name, error: e.class.name, backtrace: e.backtrace }
      )
    end
  end
end

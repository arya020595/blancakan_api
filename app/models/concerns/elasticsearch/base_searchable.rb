# frozen_string_literal: true

# Provides Elasticsearch integration for models, including async indexing and search utilities.
module Elasticsearch
  # This module provides Elasticsearch integration for models, including async indexing and search utilities.
  module BaseSearchable
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      # Don't include Elasticsearch::Model::Callbacks - we use async callbacks instead
      # This prevents synchronous indexing that blocks requests
      after_commit :async_index_document, on: %i[create update], if: :elasticsearch_enabled?
      after_commit :async_delete_document, on: :destroy, if: :elasticsearch_enabled?
    end

    # Class methods for Elasticsearch::BaseSearchable.
    # Provides search, index management, and availability checks for including models.
    module ClassMethods
      # Main search method - follows Single Responsibility Principle
      def search_with_filters(params = {})
        IndexManager.new(self).ensure_ready
        Elasticsearch::SearchFacade.new(self).execute(params)
      end

      # Index management utilities
      def elasticsearch_index_manager
        @elasticsearch_index_manager ||= IndexManager.new(self)
      end

      # Convenience methods for index management
      def reindex_elasticsearch(force: false)
        elasticsearch_index_manager.reindex_all(force: force)
      end

      def elasticsearch_index_stats
        elasticsearch_index_manager.index_stats
      end

      # Check if Elasticsearch is available
      def elasticsearch_available?
        __elasticsearch__.client.ping
      rescue StandardError
        false
      end
    end

    private

    def async_index_document
      ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
    rescue StandardError => e
      log_elasticsearch_job_failure('indexing', e)
    end

    def async_delete_document
      ReindexElasticsearchJob.perform_later(self.class.name, id.to_s, 'delete')
    rescue StandardError => e
      log_elasticsearch_job_failure('delete', e)
    end

    # Shared logging for Elasticsearch job failures
    def log_elasticsearch_job_failure(operation, error)
      HelperLogger.warn(
        "Failed to enqueue Elasticsearch #{operation} job",
        klass: self.class.name,
        extra: {
          record_id: id.to_s,
          operation: operation,
          error: error.message,
          backtrace: error.backtrace.first(3)
        }
      )
    end

    # Check if Elasticsearch indexing is enabled
    # Can be disabled via credentials configuration
    def elasticsearch_enabled?
      ::Rails.application.credentials.dig(:elasticsearch, :enabled) || false
    end
  end
end

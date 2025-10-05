# frozen_string_literal: true

module Elasticsearch
  module BaseSearchable
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      # Don't include Elasticsearch::Model::Callbacks - we use async callbacks instead
      # This prevents synchronous indexing that blocks requests

      # Async callbacks - run after transaction commits
      # Reference: "Elasticsearch: The Definitive Guide" recommends async indexing for resilience
      after_commit :async_index_document, on: %i[create update], if: :elasticsearch_enabled?
      after_commit :async_delete_document, on: :destroy, if: :elasticsearch_enabled?
    end

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

    # Async indexing - enqueues background job
    # Pattern: "Background Job" pattern from "Enterprise Integration Patterns" (Hohpe & Woolf)
    # Benefits: Non-blocking, retriable, fault-tolerant
    def async_index_document
      ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
    rescue StandardError => e
      # Log but don't raise - main operation should succeed
      # Pattern: "Let It Crash" (Erlang/Elixir philosophy adapted for Ruby)
      HelperLogger.warn(
        'Failed to enqueue Elasticsearch indexing job',
        klass: self.class.name,
        extra: {
          record_id: id.to_s,
          error: e.message,
          backtrace: e.backtrace.first(3)
        }
      )
    end

    # Async delete - enqueues background job
    # Pattern: Consistent with async_index_document for true non-blocking behavior
    def async_delete_document
      ReindexElasticsearchJob.perform_later(self.class.name, id.to_s, 'delete')
    rescue StandardError => e
      # Log but don't raise - main operation should succeed
      HelperLogger.warn(
        'Failed to enqueue Elasticsearch delete job',
        klass: self.class.name,
        extra: {
          record_id: id.to_s,
          error: e.message,
          backtrace: e.backtrace.first(3)
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

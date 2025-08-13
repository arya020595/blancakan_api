# frozen_string_literal: true

module Elasticsearch
  module BaseSearchable
    extend ActiveSupport::Concern

    included do
      include Elasticsearch::Model
      include Elasticsearch::Model::Callbacks
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
    end
  end
end

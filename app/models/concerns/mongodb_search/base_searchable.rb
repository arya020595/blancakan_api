# frozen_string_literal: true

module MongodbSearch
  module BaseSearchable
    extend ActiveSupport::Concern

    module ClassMethods
      # Main search method - follows Single Responsibility Principle
      def mongodb_search_with_filters(params = {})
        MongodbSearch::SearchFacade.new(self).execute(params)
      end
    end
  end
end

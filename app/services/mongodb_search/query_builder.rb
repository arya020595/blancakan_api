# frozen_string_literal: true

module MongodbSearch
  # QueryBuilder handles text search query construction for MongoDB
  # Follows Single Responsibility Principle - only builds queries
  class QueryBuilder
    def initialize(model_class)
      @model_class = model_class
    end

    def build(query_string)
      return {} if query_string.blank? || query_string == '*'

      # Check if model has text index
      if text_fields.any?
        build_text_search(query_string)
      else
        build_regex_search(query_string)
      end
    end

    private

    attr_reader :model_class

    def build_text_search(query_string)
      # Use MongoDB's $text search if text indexes are available
      { '$text' => { '$search' => query_string } }
    end

    def build_regex_search(query_string)
      # Fallback to regex search on searchable fields
      searchable_fields = Configuration.searchable_fields_for(@model_class)
      return {} if searchable_fields.empty?

      # Build OR condition for all searchable fields
      conditions = searchable_fields.map do |field|
        { field => { '$regex' => Regexp.escape(query_string), '$options' => 'i' } }
      end

      { '$or' => conditions }
    end

    def text_fields
      @text_fields ||= Configuration.text_fields_for(@model_class)
    end
  end
end

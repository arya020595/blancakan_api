# frozen_string_literal: true

module Elasticsearch
  # A Kaminari-compatible wrapper for Elasticsearch results
  # This provides the pagination interface expected by ServiceResponseFormatter
  class PaginatedElasticsearchResults
    include Enumerable

    def initialize(records, current_page, per_page, total_count)
      @records = records
      @current_page = current_page.to_i
      @per_page = per_page.to_i
      @total_count = total_count.to_i
    end

    # Enumerable interface
    def each(&block)
      @records.each(&block)
    end

    def to_a
      @records
    end

    def size
      @records.size
    end

    def length
      @records.length
    end

    def empty?
      @records.empty?
    end

    # Kaminari-compatible pagination interface
    attr_reader :current_page

    def next_page
      @current_page < total_pages ? @current_page + 1 : nil
    end

    def prev_page
      @current_page > 1 ? @current_page - 1 : nil
    end

    def total_pages
      (@total_count.to_f / @per_page).ceil
    end

    attr_reader :total_count

    def limit_value
      @per_page
    end

    # Additional methods for compatibility
    def first_page?
      @current_page == 1
    end

    def last_page?
      @current_page == total_pages
    end

    def out_of_range?
      @current_page > total_pages
    end
  end
end

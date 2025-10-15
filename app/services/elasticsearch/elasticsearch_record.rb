# frozen_string_literal: true

module Elasticsearch
  # A lightweight object that mimics ActiveRecord for Elasticsearch results
  # This allows direct use of ES data without database queries
  class ElasticsearchRecord
    def initialize(attributes = {})
      @attributes = attributes.with_indifferent_access
    end

    # ActiveRecord-like attribute access
    def method_missing(method_name, *args, &block)
      if @attributes.key?(method_name.to_s)
        @attributes[method_name.to_s]
      elsif method_name.to_s.end_with?('=')
        attribute_name = method_name.to_s.chomp('=')
        @attributes[attribute_name] = args.first
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @attributes.key?(method_name.to_s) ||
        method_name.to_s.end_with?('=') ||
        super
    end

    # ActiveRecord-like methods for serialization compatibility
    attr_reader :attributes

    def id
      @attributes['_id'] || @attributes['id']
    end

    def _id
      @attributes['_id'] || @attributes['id']
    end

    def to_hash
      @attributes.to_hash
    end

    def to_h
      @attributes.to_h
    end

    # For JSON serialization
    def as_json(options = {})
      @attributes.as_json(options)
    end

    def to_json(options = {})
      @attributes.to_json(options)
    end

    # ActiveModel::Serialization compatibility
    def read_attribute_for_serialization(key)
      @attributes[key]
    end

    # For debugging
    def inspect
      "#<#{self.class.name} #{@attributes.inspect}>"
    end

    def ==(other)
      other.is_a?(self.class) && @attributes == other.attributes
    end
  end
end

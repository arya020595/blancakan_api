# frozen_string_literal: true

module Elasticsearch
  module PaymentMethodSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    included do
      settings do
        mappings dynamic: false do
          indexes :display_name, type: :text, fields: { keyword: { type: :keyword, ignore_above: 256 } }
          indexes :code, type: :keyword
          indexes :payment_gateway, type: :keyword
          indexes :enabled, type: :boolean
          indexes :created_at, type: :date
          indexes :updated_at, type: :date
        end
      end
    end

    module ClassMethods
      def elasticsearch_searchable_fields
        %w[display_name code payment_gateway]
      end

      def elasticsearch_sortable_fields
        %w[display_name code payment_gateway enabled created_at updated_at _id]
      end

      def elasticsearch_boolean_fields
        %w[enabled]
      end
    end
  end
end

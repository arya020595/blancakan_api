# frozen_string_literal: true

module Organizers
  module SearchMethods
    extend ActiveSupport::Concern

    class_methods do
      def find_by_handle(handle)
        where(handle: handle.downcase).first
      end

      def search(query)
        return all if query.blank?

        where(
          '$or' => [
            { name: /#{Regexp.escape(query)}/i },
            { description: /#{Regexp.escape(query)}/i },
            { handle: /#{Regexp.escape(query)}/i }
          ]
        )
      end

      def search_by_text(query)
        # Use MongoDB text search if available, fallback to regex search
        if respond_to?(:text_search)
          text_search(query)
        else
          search(query)
        end
      end

      def with_events
        where(:id.in => Event.distinct(:organizer_id))
      end

      def by_status(status)
        case status.to_s
        when 'active'
          active
        when 'inactive'
          inactive
        else
          all
        end
      end

      def popular(limit = 10)
        # Get organizers with most published events
        organizer_event_counts = Event.where(status: 'published')
                                      .group(:organizer_id)
                                      .count

        top_organizer_ids = organizer_event_counts
                            .sort_by { |_, count| -count }
                            .first(limit)
                            .map { |organizer_id, _| organizer_id }

        where(:id.in => top_organizer_ids)
      end

      def search_by_text(query)
        return all if query.blank?

        # Use MongoDB text search if available, otherwise fallback to regex
        if collection.indexes.any? { |index| index['key'].keys.include?('_fts') }
          where('$text' => { '$search' => query })
        else
          search(query)
        end
      end
    end
  end
end

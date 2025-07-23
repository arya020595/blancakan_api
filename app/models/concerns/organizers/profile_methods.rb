# frozen_string_literal: true

module Organizers
  module ProfileMethods
    extend ActiveSupport::Concern

    # Instance methods for organizer profile management
    def display_name
      name.presence || handle
    end

    def public_profile_url
      "/organizers/#{handle}"
    end

    def has_contact_info?
      contact_phone.present?
    end

    def has_avatar?
      image_service.has_image?
    end

    def avatar_url(version = nil)
      image_service.image_url(version)
    end

    def avatar_thumb_url
      avatar_url(:thumb)
    end

    def avatar_medium_url
      avatar_url(:medium)
    end

    def avatar_filename
      image_service.image_filename
    end

    def avatar_size
      image_service.image_size
    end

    def avatar_content_type
      image_service.image_content_type
    end

    def display_contact_phone
      # Only show partial phone number for public display
      return nil unless contact_phone.present?

      if contact_phone.length > 6
        masked = '*' * (contact_phone.length - 4)
        "#{masked}#{contact_phone.last(4)}"
      else
        contact_phone
      end
    end

    def social_stats
      {
        total_events: events_count,
        active_events: active_events_count,
        member_since: created_at.strftime('%B %Y')
      }
    end

    private

    def image_service
      @image_service ||= V1::Organizers::ImageService.new(self)
    end
  end
end

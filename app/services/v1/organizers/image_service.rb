# frozen_string_literal: true

module V1
  module Organizers
    class ImageService
      def initialize(organizer)
        @organizer = organizer
      end

      def destroy_previous_image_if_changed
        return unless @organizer.avatar_changed?

        previous_avatar = @organizer.avatar_was
        return unless previous_avatar.present?

        # Remove the previous avatar file
        previous_avatar.remove!
      rescue StandardError => e
        Rails.logger.error "Failed to remove previous organizer avatar: #{e.message}"
      end

      def destroy_current_image
        return unless @organizer.avatar.present?

        @organizer.avatar.remove!
      rescue StandardError => e
        Rails.logger.error "Failed to remove current organizer avatar: #{e.message}"
      end

      # Additional helper methods for avatar management
      def has_image?
        @organizer.avatar.present?
      end

      def image_url(version = nil)
        return nil unless has_image?

        version ? @organizer.avatar.url(version) : @organizer.avatar.url
      end

      def image_versions
        return [] unless has_image?

        @organizer.avatar.versions.keys
      end

      def image_size
        return nil unless has_image?

        @organizer.avatar.file&.size
      end

      def image_filename
        return nil unless has_image?

        @organizer.avatar.file&.filename
      end

      def image_content_type
        return nil unless has_image?

        @organizer.avatar.file&.content_type
      end
    end
  end
end

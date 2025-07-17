# frozen_string_literal: true

module V1
  module Events
    class ImageService
      def initialize(event)
        @event = event
      end

      def destroy_previous_image_if_changed
        return unless @event.cover_image_changed?
        return unless @event.cover_image_was.present?

        destroy_image(@event.cover_image_was)
      end

      def destroy_current_image
        return unless @event.cover_image.present?

        destroy_image(@event.cover_image)
      end

      private

      def destroy_image(image_url)
        return unless image_url&.file&.public_id

        Cloudinary::Uploader.destroy(image_url.file.public_id)
      rescue StandardError => e
        Rails.logger.error "Failed to destroy image: #{e.message}"
      end
    end
  end
end

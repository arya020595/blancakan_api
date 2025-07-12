# frozen_string_literal: true

module EventSlugGenerator
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug_and_short_id, on: :create
  end

  private

  def generate_slug_and_short_id
    return if title.blank?

    base_slug = title.parameterize
    self.short_id = generate_unique_short_id
    self.slug = "#{base_slug}-#{short_id}"
  end

  def generate_unique_short_id
    loop do
      short_id = SecureRandom.alphanumeric(6)
      break short_id unless Event.where(short_id: short_id).exists?
    end
  end
end

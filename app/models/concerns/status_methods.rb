# frozen_string_literal: true

module StatusMethods
  extend ActiveSupport::Concern

  # Instance methods for status management
  # Works with any model that has an `is_active` boolean field
  def active?
    is_active
  end

  def inactive?
    !is_active
  end

  def activate!
    update!(is_active: true)
  end

  def deactivate!
    update!(is_active: false)
  end

  def toggle_status!
    update!(is_active: !is_active)
  end

  def status
    active? ? 'active' : 'inactive'
  end

  module ClassMethods
    def active
      where(is_active: true)
    end

    def inactive
      where(is_active: false)
    end

    def by_status(status)
      case status.to_s.downcase
      when 'active', 'true', '1'
        active
      when 'inactive', 'false', '0'
        inactive
      else
        all
      end
    end
  end
end

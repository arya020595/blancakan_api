# frozen_string_literal: true

module PayoutMethods
  module SingleActivePerUser
    extend ActiveSupport::Concern

    included do
      validate :only_one_active_per_user
      
      # Scope to get active records for a user
      scope :active_for_user, ->(user) { where(user: user, is_active: true) }
    end

    class_methods do
      def deactivate_all_for_user(user)
        where(user: user, is_active: true).update_all(is_active: false)
      end
      
      def activate_for_user(user, record_id)
        transaction do
          deactivate_all_for_user(user)
          find(record_id).update!(is_active: true)
        end
      end
      
      def active_record_for_user(user)
        active_for_user(user).first
      end
    end

    # Instance methods
    def activate_as_primary!
      self.class.transaction do
        # Deactivate all other records for this user
        self.class.where(user: user, is_active: true)
                  .where(:_id.ne => _id)
                  .update_all(is_active: false)
        
        # Activate this record
        update!(is_active: true)
      end
    end

    def other_active_records_for_user
      return self.class.none unless user_id.present?
      
      scope = self.class.where(user_id: user_id, is_active: true)
      scope = scope.where(:_id.ne => _id) if persisted?
      scope
    end

    private

    def only_one_active_per_user
      return unless is_active? && user_id.present?
      return unless other_active_records_for_user.exists?

      model_name = self.class.name.underscore.humanize.downcase
      errors.add(:base, "Only one active #{model_name} allowed per user")
    end
  end
end

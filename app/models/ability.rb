# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present? # Guests have no permissions

    role = user.role
    if role.blank?
      cannot :manage, :all # Explicitly deny all access if no role
      return
    end

    if role.name == 'superadmin'
      can :manage, :all # Superadmin has full access
      return
    end

    # Grant permissions based on role
    role.permissions.each do |permission|
      action = permission.action.to_sym
      model_class = permission.subject_class.classify.safe_constantize
      next unless model_class

      if permission.conditions.present?
        conditions = permission.conditions.deep_symbolize_keys
        can action, model_class, conditions
      else
        can action, model_class
      end
    end
  end
end

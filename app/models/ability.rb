# frozen_string_literal: true

# Defines authorization rules using CanCanCan.
# - Guests: no permissions.
# - No role: denied all access.
# - Superadmins: full access.
# - Others: permissions based on role.
#
# == Condition Placeholders
# Conditions support dynamic placeholders that reference the current user:
# - "user.id"              => current_user.id
# - "user.organization_id" => current_user.organization_id
# - "user.role.name"       => current_user.role.name
#
# Example permission in database:
#   {
#     action: "destroy",
#     subject_class: "Event",
#     conditions: { "organizer_id": "user.organizer.id" }
#   }
#
# This becomes:
#   can :destroy, Event, organizer_id: BSON::ObjectId('68ea18c0eefe3decc4013243')
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present? # Guests have no permissions

    @user = user # Store user for condition processing
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
        # Process placeholders in conditions
        conditions = process_conditions(permission.conditions)
        can action, model_class, conditions
      else
        can action, model_class
      end
    end
  end

  private

  # Processes condition placeholders by replacing string references with actual values
  #
  # Supports dynamic placeholders in format "context.attribute.nested"
  # Currently supports "user.*" context, extensible for future contexts
  #
  # @param conditions [Hash] The conditions hash from permission
  # @return [Hash] Processed conditions with replaced values
  #
  # @example
  #   process_conditions({ "organizer_id" => "user.organizer.id" })
  #   # => { organizer_id: BSON::ObjectId('68ea18c0eefe3decc4013243') }
  #
  #   process_conditions({ "organization_id" => "user.organization.id" })
  #   # => { organization_id: BSON::ObjectId('507f1f77bcf86cd799439011') }
  def process_conditions(conditions)
    conditions.deep_symbolize_keys.transform_values { |value| resolve_placeholder(value) }
  end

  # Resolves a placeholder string to its actual value
  #
  # @param value [Object] The value to resolve (only processes strings)
  # @return [Object] The resolved value or original value if not a placeholder
  def resolve_placeholder(value)
    return value unless value.is_a?(String) && value.include?('.')

    context, *attributes = value.split('.')
    return value unless context == 'user'

    resolve_method_chain(@user, attributes)
  end

  # Resolves a method chain on an object
  #
  # @param object [Object] The starting object
  # @param methods [Array<String>] Array of method names to call sequentially
  # @return [Object] The final result, preserving MongoDB native types like BSON::ObjectId
  def resolve_method_chain(object, methods)
    result = methods.reduce(object) { |obj, method| obj&.public_send(method) }
    normalize_for_mongodb(result)
  end

  # Single responsibility: Keep values in their original MongoDB-compatible types
  # Note: BSON::ObjectId must remain as-is for CanCanCan to properly match conditions
  # with Mongoid model attributes. Converting to String breaks object comparisons.
  def normalize_for_mongodb(value)
    return value if value.is_a?(BSON::ObjectId)

    if value.is_a?(String) && BSON::ObjectId.legal?(value)
      BSON::ObjectId.from_string(value)
    else
      value
    end
  end
end
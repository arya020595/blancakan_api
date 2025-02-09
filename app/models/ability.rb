# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present? # Guest users have no permissions

    if user.has_role?(:superadmin)
      can :manage, :all
    elsif user.has_role?(:admin)
      can :manage, User
      can :read, Event # Admins can only read events
    elsif user.has_role?(:organizer)
      can :create, Event
      can :read, Event
      can %i[update destroy], Event, user_id: user.id # Only update/delete own events
    elsif user.has_role?(:premium_organizer)
      can :create, Event
      can :read, Event
      can %i[update destroy], Event, user_id: user.id
      can :create, Ticket # Premium organizers can create tickets
    end

    # Apply additional permissions from database
    user.permissions.each do |permission|
      action, model_name = permission.name.split('_', 2) # Extract action and model name
      model_class = model_name.classify.safe_constantize # Convert string to model class

      can action.to_sym, model_class if model_class
    end
  end
end

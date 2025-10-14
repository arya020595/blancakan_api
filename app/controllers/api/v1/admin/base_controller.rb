# frozen_string_literal: true

module Api
  module V1
    module Admin
      class BaseController < Api::BaseController
        include ServiceResponseFormatter
        include Authenticatable

        load_and_authorize_resource
        before_action :set_collection_for_index, only: [:index]

        private

        # Required by CanCanCan to determine user abilities
        # Returns an Ability instance initialized with the current user
        def current_ability
          @current_ability ||= Ability.new(current_user)
        end

        # Automatically set filtered collection for index actions
        # Sets @events, @users, @organizers, etc. based on controller name
        def set_collection_for_index
          # Get model class from controller name (e.g., EventsController -> Event)
          model_class = controller_name.classify.constantize
          collection_name = "@#{controller_name}"
          
          # Get filtered scope and set instance variable
          filtered_scope = accessible_scope(model_class, :read)
          instance_variable_set(collection_name, filtered_scope)
        end

        # Helper method to get filtered scope for Mongoid models
        # CanCanCan's load_and_authorize_resource doesn't work well with Mongoid for index actions
        # This method manually extracts conditions from ability and creates a filtered scope
        def accessible_scope(model_class, action = :read)
          authorize! action, model_class
          
          # Get all relevant rules for this action and model
          rules = current_ability.send(:relevant_rules, action, model_class)
          rule_with_conditions = rules.find { |r| r.base_behavior && r.conditions.present? }
          
          if rule_with_conditions
            # Apply conditions to create filtered scope
            model_class.where(rule_with_conditions.conditions)
          else
            # No conditions means either full access or no access
            # If we got here, authorize! passed, so it's full access
            model_class.all
          end
        end
      end
    end
  end
end

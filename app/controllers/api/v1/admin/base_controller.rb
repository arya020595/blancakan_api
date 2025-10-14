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
        def current_ability
          @current_ability ||= Ability.new(current_user)
        end

        # Automatically set filtered collection for index actions
        # Sets @events, @users, @organizers, etc. based on controller name
        def set_collection_for_index
          model_class = controller_name.classify.constantize
          collection_name = "@#{controller_name}"
          
          # Get filtered scope (includes authorization check)
          filtered_scope = build_filtered_scope(model_class)
          instance_variable_set(collection_name, filtered_scope)
        end

        # Build filtered scope based on CanCanCan ability conditions
        def build_filtered_scope(model_class)
          # First check if user can read this model
          authorize! :read, model_class
          
          rules = current_ability.send(:relevant_rules, :read, model_class)
          rule_with_conditions = rules.find { |r| r.base_behavior && r.conditions.present? }
          
          if rule_with_conditions
            # Has conditions - apply filter
            model_class.where(rule_with_conditions.conditions)
          else
            # No conditions - only allow if user has :manage, :all (superadmin)
            manage_all_rule = rules.find { |r| r.base_behavior && r.subjects.include?(:all) }
            if manage_all_rule
              model_class.all
            else
              # Has permission but no conditions and not superadmin - deny access
              raise CanCan::AccessDenied.new("Not authorized to access #{model_class.name} without conditions", :read, model_class)
            end
          end
        end
      end
    end
  end
end

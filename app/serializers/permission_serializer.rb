# frozen_string_literal: true

class PermissionSerializer < ActiveModel::Serializer
  attributes :id, :action, :subject_class, :conditions, :role_id, :role_name, :created_at, :updated_at

  def role_name
    object.role&.name
  end
end

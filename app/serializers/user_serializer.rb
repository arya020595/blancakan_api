class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :authorization

  def authorization
    token = instance_options[:token]
    "Bearer #{token}" if token.present?
  end
end

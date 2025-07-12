# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    include DeviseTokenAuth::Concerns::SetUserByToken

    rescue_from CanCan::AccessDenied do |exception|
      render json: { error: exception.message }, status: :forbidden
    end
  end
end

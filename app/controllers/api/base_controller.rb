# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    rescue_from CanCan::AccessDenied do |exception|
      render json: { error: exception.message }, status: :forbidden
    end
  end
end

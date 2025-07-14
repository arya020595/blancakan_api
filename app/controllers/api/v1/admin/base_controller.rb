# frozen_string_literal: true

module Api
  module V1
    module Admin
      class BaseController < Api::BaseController
        include ServiceResponseFormatter
        include Authenticatable

        load_and_authorize_resource
      end
    end
  end
end

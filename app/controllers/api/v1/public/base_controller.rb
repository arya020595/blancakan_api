# frozen_string_literal: true

module Api
  module V1
    module Public
      class BaseController < Api::BaseController
        include ServiceResponseFormatter

        # Public endpoints don't require authentication by default
        # but can implement it on a per-controller basis
      end
    end
  end
end

# frozen_string_literal: true

module Auth
  class AuthController < ApplicationController
    # POST /auth/login
    def login
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        token = JwtService.encode(user_id: user.id.to_s)
        render json: UserSerializer.new(user, token: token).as_json, status: :ok
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
  end
end

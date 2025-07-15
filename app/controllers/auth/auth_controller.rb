# frozen_string_literal: true

module Auth
  class AuthController < ApplicationController
    include ServiceResponseFormatter
    include Dry::Monads[:result]

    # POST /auth/sign_in
    def sign_in
      user = User.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        token = JwtService.encode(user_id: user.id.to_s)
        result = Success(user)
        format_response(result: result, resource: 'users',
                        action: :sign_in, serializer: [UserSerializer, { token: token }])
      else
        result = Failure(nil)
        format_response(result: result, resource: 'users', action: :sign_in)
      end
    end

    # POST /auth/register
    def register
      user = User.new(register_params)
      if user.save
        token = JwtService.encode(user_id: user.id.to_s)
        result = Success(user)
        format_response(result: result, resource: 'users',
                        action: :register, serializer: [UserSerializer, { token: token }])
      else
        result = Failure(user.errors.full_messages)
        format_response(result: result, resource: 'users', action: :register)
      end
    end

    # POST /auth/sign_out
    def sign_out
      # Since JWT tokens are stateless, we can't invalidate them server-side
      # In a real application, you might want to:
      # - Add token to a blacklist
      # - Store tokens in Redis and remove them
      # - Use shorter token expiration times

      result = Success({ message: 'Successfully signed out' })
      format_response(result: result, resource: 'users', action: :sign_out)
    end

    private

    def register_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role_id)
    end
  end
end

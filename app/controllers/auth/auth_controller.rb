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
        format_response(result: result, resource: 'users', action: :sign_in,
                        serializer: [UserSerializer, { token: token }])
      else
        result = Failure(nil)
        format_response(result: result, resource: 'users', action: :sign_in)
      end
    end
  end
end

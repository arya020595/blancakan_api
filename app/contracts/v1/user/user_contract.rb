# frozen_string_literal: true

module V1
  module User
    class UserContract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        required(:email).filled(:string)
        required(:password).filled(:string)
        optional(:role_id).maybe(:string)
      end
      rule(:email) do
        key.failure('must be a valid email') unless value =~ URI::MailTo::EMAIL_REGEXP
      end
    end
  end
end

# frozen_string_literal: true

module V1
  module User
    class UserForm
      include ActiveModel::Model

      attr_accessor :name, :email, :password, :role_id

      def initialize(params = {})
        super(params)
        @contract = ::V1::User::UserContract.new
      end

      def valid?
        @validation_result = @contract.call(attributes)
        @validation_result.success?
      end

      def errors
        raise 'You must call `valid?` before accessing `errors`' unless @validation_result

        ActiveModel::Errors.new(self).tap do |am_errors|
          @validation_result.errors.to_h.each do |field, messages|
            Array(messages).each { |msg| am_errors.add(field, msg) }
          end
        end
      end

      def attributes
        {
          name: name,
          email: email,
          password: password,
          role_id: role_id
        }
      end
    end
  end
end

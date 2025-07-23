# frozen_string_literal: true

module V1
  module Organizer
    class OrganizerForm
      include ActiveModel::Model

      attr_accessor :name, :description, :handle, :contact_phone, :user_id, :avatar, :is_active

      def initialize(params = {})
        super(params)
        @contract = ::V1::Organizer::OrganizerContract.new
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
          description: description,
          handle: handle,
          contact_phone: contact_phone,
          user_id: user_id,
          avatar: avatar,
          is_active: is_active
        }.compact
      end
    end
  end
end

# frozen_string_literal: true

module V1
  # Service class for managing ticket types
  class TicketTypeService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      ticket_types = ::TicketType.search(query: query, page: page, per_page: per_page)
      Success(ticket_types)
    end

    def show(ticket_type)
      return Failure(nil) unless ticket_type

      Success(ticket_type)
    end

    def create(params)
      form = ::V1::TicketType::TicketTypeForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      ticket_type = ::TicketType.new(form.attributes)
      if ticket_type.save
        Success(ticket_type)
      else
        Failure(ticket_type.errors.full_messages)
      end
    end

    def update(ticket_type, params)
      form = ::V1::TicketType::TicketTypeForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if ticket_type.update(form.attributes)
        Success(ticket_type)
      else
        Failure(ticket_type.errors.full_messages)
      end
    end

    def destroy(ticket_type)
      return Failure(nil) unless ticket_type

      if ticket_type.destroy
        Success(ticket_type)
      else
        Failure(ticket_type.errors.full_messages)
      end
    end
  end
end

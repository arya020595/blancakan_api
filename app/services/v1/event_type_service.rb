# frozen_string_literal: true

module V1
  # Service class for managing event types
  class EventTypeService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      event_types = ::EventType.search(query: query, page: page, per_page: per_page)
      Success(event_types)
    end

    def show(event_type)
      return Failure('Event type not found') unless event_type

      Success(event_type)
    end

    def create(params)
      form = ::V1::EventType::EventTypeForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      event_type = ::EventType.new(form.attributes)
      if event_type.save
        Success(event_type)
      else
        Failure(event_type.errors.full_messages)
      end
    end

    def update(event_type, params)
      form = ::V1::EventType::EventTypeForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if event_type.update(form.attributes)
        Success(event_type)
      else
        Failure(event_type.errors.full_messages)
      end
    end

    def destroy(event_type)
      return Failure('Event type not found') unless event_type

      if event_type.destroy
        Success('Event type deleted')
      else
        Failure(event_type.errors.full_messages)
      end
    end
  end
end

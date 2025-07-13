# frozen_string_literal: true

module V1
  # Service class for managing events
  class EventService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      events = ::Event.search(query: query, page: page, per_page: per_page)
      Success(events)
    end

    def show(event)
      return Failure('Event not found') unless event

      Success(event)
    end

    def create(params)
      form = ::V1::Event::EventForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      event = ::Event.new(form.attributes)
      if event.save
        Success(event)
      else
        Failure(event.errors.full_messages)
      end
    end

    def update(event, params)
      form = ::V1::Event::EventForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if event.update(form.attributes)
        Success(event)
      else
        Failure(event.errors.full_messages)
      end
    end

    def destroy(event)
      return Failure('Event not found') unless event

      if event.destroy
        Success('Event deleted')
      else
        Failure(event.errors.full_messages)
      end
    end
  end
end

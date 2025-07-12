# frozen_string_literal: true

module V1
  # Service class for managing events
  class EventService
    include Dry::Monads[:result]

    def index(query: '*', page: 1, per_page: 10)
      events = Event.search(query: query, page: page, per_page: per_page)
      Success(events)
    rescue StandardError => e
      Failure(e.message)
    end

    def show(id)
      event = Event.find(id)
      if event
        Success(event)
      else
        Failure('Event not found')
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def create(params)
      event = Event.new(params)
      if event.save
        Success(event)
      else
        Failure(event.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def update(event, params)
      if event.update(params)
        Success(event)
      else
        Failure(event.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def destroy(event)
      if event.destroy
        Success('Event deleted')
      else
        Failure(event.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end
  end
end

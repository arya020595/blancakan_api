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

    def show(event)
      return Failure('Event not found') unless event

      Success(event)
    rescue StandardError => e
      Failure(e.message)
    end

    def create(params)
      contract = ::V1::Event::EventContract.new
      result = contract.call(params)
      return Failure(result.errors.to_h) if result.failure?

      event = Event.new(result.to_h)
      if event.save
        Success(event)
      else
        Failure(event.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def update(event, params)
      contract = ::V1::Event::EventContract.new
      result = contract.call(params)
      return Failure(result.errors.to_h) if result.failure?

      if event.update(result.to_h)
        Success(event)
      else
        Failure(event.errors.full_messages)
      end
    rescue StandardError => e
      Failure(e.message)
    end

    def destroy(event)
      return Failure('Event not found') unless event

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

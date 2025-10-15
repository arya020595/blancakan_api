# frozen_string_literal: true

module V1
  # Service class for managing events
  class EventService
    include Dry::Monads[:result]

    def index(scope, params = {})
      events = scope.mongodb_search_with_filters(params)

      Success(events)
    end

    def show(event)
      return Failure(nil) unless event

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
      return Failure(nil) unless event

      if event.destroy
        Success(event)
      else
        Failure(event.errors.full_messages)
      end
    end
  end
end

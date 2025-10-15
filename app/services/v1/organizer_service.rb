# frozen_string_literal: true

module V1
  # Service class for managing organizers
  class OrganizerService
    include Dry::Monads[:result]

    def index(scope, params = {})
      organizers = scope.mongodb_search_with_filters(params)

      Success(organizers)
    end

    def show(organizer)
      return Failure(nil) unless organizer

      Success(organizer)
    end

    def create(params)
      form = ::V1::Organizer::OrganizerForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      organizer = ::Organizer.new(form.attributes)
      if organizer.save
        Success(organizer)
      else
        Failure(organizer.errors.full_messages)
      end
    end

    def update(organizer, params)
      form = ::V1::Organizer::OrganizerForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if organizer.update(form.attributes)
        Success(organizer)
      else
        Failure(organizer.errors.full_messages)
      end
    end

    def destroy(organizer)
      return Failure(nil) unless organizer

      if organizer.destroy
        Success(organizer)
      else
        Failure(organizer.errors.full_messages)
      end
    end
  end
end

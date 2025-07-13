# frozen_string_literal: true

# Example API Controller showing proper validation flow
class Api::V1::EventsController < ApplicationController
  def create
    # Input validation happens BEFORE hitting the model
    result = EventCreationService.call(event_params)

    case result
    in Success(event)
      render json: event, status: :created
    in Failure(errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find(params[:id])

    # Input validation first
    validation_result = EventInputValidator.validate(event_params)

    if validation_result.failure?
      render json: { errors: validation_result.failure }, status: :unprocessable_entity
      return
    end

    # Update with validated params
    if event.update(validation_result.value!)
      render json: event
    else
      # Database integrity validation errors
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :title, :description, :start_date, :start_time, :end_date, :end_time,
      :location_type, :timezone, :event_type_id, :organizer_id,
      :cover_image_url, :status, :is_paid,
      location: {}, category_ids: []
    )
  end
end

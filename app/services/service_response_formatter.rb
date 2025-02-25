# frozen_string_literal: true

# This module provides a standardized way to format service responses.
# It ensures that the result object follows the correct pattern and renders
# the appropriate JSON response based on the success or failure of the service call.
module ServiceResponseFormatter
  # Formats the response based on the result of a service call.
  #
  # @param result [Object] The result object which should respond to :success?, :value!, and :failure.
  # @param resource [Symbol] The resource symbol used for I18n translation.
  # @param action [Symbol] The action symbol used for I18n translation and HTTP status determination.
  # @param serializer [Class, nil] The optional serializer class for formatting the response data.
  def format_response(result:, resource:, action:, serializer: nil)
    validate_result_pattern(result)

    if result.success?
      render_success_response(result, resource, action, serializer)
    else
      render_error_response(result, resource, action)
    end
  end

  private

  def validate_result_pattern(result)
    required_methods = %i[success? value! failure]
    missing_methods = required_methods.reject { |method| result.respond_to?(method) }

    return if missing_methods.empty?

    raise ArgumentError, "Result object is missing required methods: #{missing_methods.join(', ')}"
  end

  def render_success_response(result, resource, action, serializer)
    data = result.value!
    response = {
      status: 'success',
      message: I18n.t("#{resource}.#{action}.success"),
      data: serialize_data(data, serializer)
    }
    response[:meta] = pagination_meta(data) if data.respond_to?(:current_page)
    render json: response, status: http_success_status(action)
  end

  def render_error_response(result, resource, action)
    render json: {
      status: 'error',
      message: I18n.t("#{resource}.#{action}.error"),
      errors: result.failure
    }, status: http_error_status(action)
  end

  def serialize_data(data, serializer)
    return data unless serializer

    cached_serializer(serializer).new(data).as_json
  end

  def cached_serializer(serializer)
    @cached_serializers ||= {}
    @cached_serializers[serializer] ||= ActiveModelSerializers::SerializableResource
  end

  def http_success_status(action)
    case action
    when :create
      :created
    when :update
      :ok
    when :destroy
      :no_content
    else
      :ok
    end
  end

  def http_error_status(action)
    case action
    when :show
      :not_found
    when :create, :update
      :unprocessable_entity
    when :destroy
      :not_found
    else
      :bad_request
    end
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end

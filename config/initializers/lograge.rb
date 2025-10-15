Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = 'ActionController::API'
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      user_id: controller.instance_variable_get(:@current_user)&.id,
      request_id: controller.request.uuid,
      error_message: controller.request.env['lograge.error_message'],
      errors: controller.request.env['lograge.errors']
    }
  end

  config.lograge.custom_options = lambda { |event|
    {
      timestamp: Time.current.utc.iso8601,
      request_id: event.payload[:request_id],
      user_id: event.payload[:user_id],
      params: event.payload[:params].except('controller', 'action'),
      tags: ['api'],
      host: event.payload[:host],
      error_message: event.payload[:error_message],
      errors: event.payload[:errors]
    }
  }
end

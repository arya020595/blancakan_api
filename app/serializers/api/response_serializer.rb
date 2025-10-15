# app/serializers/api/response_serializer.rb
module Api
  class ResponseSerializer
    def initialize(**dependencies)
      # Accept DI parameters even if not used
    end

    def success(data: nil, message: nil, meta: nil)
      response = {
        status: 'success',
        message: message,
        data: data
      }
      response[:meta] = meta if meta
      response
    end

    def error(errors: nil, message: nil, meta: nil)
      response = {
        status: 'error',
        message: message,
        errors: errors
      }
      response[:meta] = meta if meta
      response
    end
  end
end

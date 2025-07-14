class Api::V1::Admin::HomeController < Api::V1::Admin::BaseController
  def index
    render json: { message: 'Welcome to the API' }
  end
end

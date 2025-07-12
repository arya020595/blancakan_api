class Api::V1::Admin::HomeController < BaseController
  before_action :authenticate_user!

  def index
    render json: { message: 'Welcome to the API' }
  end
end

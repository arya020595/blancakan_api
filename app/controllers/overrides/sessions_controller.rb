class Overrides::SessionsController < DeviseTokenAuth::SessionsController
  protected

  def render_create_success
    # Ensure auth headers are updated before extracting the token
    update_auth_header
    bearer_token = response.headers['Authorization'] || response.headers['authorization']
    render json: {
      status: 'success',
      data: UserSerializer.new(@resource, token: bearer_token&.split(' ')&.last).as_json
    }, status: :ok
  end
end

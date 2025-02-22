require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  # Create a role with the name 'superadmin'
  let(:role) { create(:role, name: 'superadmin') }

  # Create a user with the 'superadmin' role
  let(:user) { create(:user, role: role) }

  # Generate authentication headers for the created user
  let(:auth_headers) { user.create_new_auth_token }

  # Test suite for GET /api/v1/admin/users
  describe 'GET /api/v1/admin/users' do
    before do
      # Create a list of 2 users
      create_list(:user, 2)
      # Make a GET request to the users endpoint with authentication headers
      get '/api/v1/admin/users', headers: auth_headers
    end

    it 'returns all users' do
      # Expect the response to have HTTP status 200 (OK)
      expect(response).to have_http_status(200)
      # Expect the JSON response to contain 3 users. Including the initial 'user'
      expect(json['data'].size).to eq(3)
    end
  end

  # Test suite for POST /api/v1/admin/users
  describe 'POST /api/v1/admin/users' do
    let(:role1) { create(:role) }

    # Define valid attributes for creating a user
    let(:valid_attributes) do
      { user:
        { name: 'John Doe', email: 'john.doe@example.com', password: 'password', password_confirmation: 'password',
          role_id: role1.id } }
    end

    context 'when the request is valid' do
      before do
        # Make a POST request to create a user with valid attributes
        post '/api/v1/admin/users', params: valid_attributes, headers: auth_headers
      end

      it 'creates a user' do
        # Expect the response to have HTTP status 201 (Created)
        expect(response).to have_http_status(201)
        # Expect the JSON response to contain the user name
        expect(json['data']['name']).to eq('John Doe')
      end
    end

    context 'when the request is invalid' do
      before do
        # Make a POST request to create a user with invalid attributes
        post '/api/v1/admin/users',
             params: { user: { name: '', email: '', password: '', role_id: '' } }, headers: auth_headers
      end

      it 'returns status code 422' do
        # Expect the response to have HTTP status 422 (Unprocessable Entity)
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for GET /api/v1/admin/users/:id
  describe 'GET /api/v1/admin/users/:id' do
    let(:user1) { create(:user) }

    context 'when the record exists' do
      before { get "/api/v1/admin/users/#{user1.id}", headers: auth_headers }

      it 'returns the user' do
        # Expect the response to have HTTP status 200 (OK)
        expect(response).to have_http_status(200)
        # Expect the JSON response to contain the user ID
        expect(json['data']['id']).to eq(user1.id.to_s)
      end
    end

    context 'when the record does not exist' do
      before { get '/api/v1/admin/users/invalid', headers: auth_headers }

      it 'returns status code 404' do
        # Expect the response to have HTTP status 404 (Not Found)
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for PUT /api/v1/admin/users/:id
  describe 'PUT /api/v1/admin/users/:id' do
    let(:user1) { create(:user) }
    let(:valid_attributes) do
      { user: { name: 'Updated Name', email: 'updated.email@example.com', password: 'newpassword' } }
    end

    context 'when the record exists' do
      before { put "/api/v1/admin/users/#{user1.id}", params: valid_attributes, headers: auth_headers }

      it 'updates the record' do
        # Expect the response to have HTTP status 200 (OK)
        expect(response).to have_http_status(200)
        # Expect the user name to be updated
        expect(user1.reload.name).to eq('Updated Name')
      end
    end

    context 'when the request is invalid' do
      before do
        put "/api/v1/admin/users/#{user1.id}",
            params: { user: { name: '', email: '', password: '' } }, headers: auth_headers
      end

      it 'returns status code 422' do
        # Expect the response to have HTTP status 422 (Unprocessable Entity)
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for DELETE /api/v1/admin/users/:id
  describe 'DELETE /api/v1/admin/users/:id' do
    let!(:user1) { create(:user) }

    context 'when the record exists' do
      before { delete "/api/v1/admin/users/#{user1.id}", headers: auth_headers }

      it 'deletes the record' do
        # Expect the response to have HTTP status 204 (No Content)
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exist' do
      before { delete '/api/v1/admin/users/invalid', headers: auth_headers }

      it 'returns status code 404' do
        # Expect the response to have HTTP status 404 (Not Found)
        expect(response).to have_http_status(404)
      end
    end
  end
end

# Helper method to parse JSON responses
def json
  JSON.parse(response.body)
end

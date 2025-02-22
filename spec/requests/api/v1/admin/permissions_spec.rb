require 'rails_helper'

RSpec.describe 'Permissions API', type: :request do
  # Create a role with the name 'superadmin'
  let(:role) { create(:role, name: 'superadmin') }

  # Create a user with the 'superadmin' role
  let(:user) { create(:user, role: role) }

  # Generate authentication headers for the created user
  let(:auth_headers) { user.create_new_auth_token }

  # Test suite for GET /api/v1/admin/permissions
  describe 'GET /api/v1/admin/permissions' do
    before do
      # Create a list of 2 permissions
      create_list(:permission, 2)
      # Make a GET request to the permissions endpoint with authentication headers
      get '/api/v1/admin/permissions', headers: auth_headers
    end

    it 'returns all permissions' do
      # Expect the response to have HTTP status 200 (OK)
      expect(response).to have_http_status(200)
      # Expect the JSON response to contain 2 permissions
      expect(json['data'].size).to eq(2)
    end
  end

  # Test suite for POST /api/v1/admin/permissions
  describe 'POST /api/v1/admin/permissions' do
    # Define valid attributes for creating a permission
    let(:valid_attributes) do
      { permission: { action: 'read', subject_class: 'User', role_id: role.id } }
    end

    context 'when the request is valid' do
      before do
        # Make a POST request to create a permission with valid attributes
        post '/api/v1/admin/permissions', params: valid_attributes, headers: auth_headers
      end

      it 'creates a permission' do
        # Expect the response to have HTTP status 201 (Created)
        expect(response).to have_http_status(201)
        # Expect the JSON response to contain the action 'read'
        expect(json['data']['action']).to eq('read')
      end
    end

    context 'when the request is invalid' do
      before do
        # Make a POST request to create a permission with invalid attributes
        post '/api/v1/admin/permissions',
             params: { permission: { action: '', subject_class: '', role_id: '' } }, headers: auth_headers
      end

      it 'returns status code 422' do
        # Expect the response to have HTTP status 422 (Unprocessable Entity)
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for GET /api/v1/admin/permissions/:id
  describe 'GET /api/v1/admin/permissions/:id' do
    let(:permission) { create(:permission) }

    context 'when the record exists' do
      before { get "/api/v1/admin/permissions/#{permission.id}", headers: auth_headers }

      it 'returns the permission' do
        # Expect the response to have HTTP status 200 (OK)
        expect(response).to have_http_status(200)
        # Expect the JSON response to contain the permission ID
        expect(json['data']['_id']).to eq(permission.id.to_s)
      end
    end

    context 'when the record does not exist' do
      before { get '/api/v1/admin/permissions/invalid', headers: auth_headers }

      it 'returns status code 404' do
        # Expect the response to have HTTP status 404 (Not Found)
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for PUT /api/v1/admin/permissions/:id
  describe 'PUT /api/v1/admin/permissions/:id' do
    let(:permission) { create(:permission) }
    let(:valid_attributes) { { permission: { action: 'manage' } } }

    context 'when the record exists' do
      before { put "/api/v1/admin/permissions/#{permission.id}", params: valid_attributes, headers: auth_headers }

      it 'updates the record' do
        # Expect the response to have HTTP status 200 (OK)
        expect(response).to have_http_status(200)
        # Expect the permission action to be updated to 'manage'
        expect(permission.reload.action).to eq('manage')
      end
    end

    context 'when the request is invalid' do
      before do
        put "/api/v1/admin/permissions/#{permission.id}", params: { permission: { action: '' } }, headers: auth_headers
      end

      it 'returns status code 422' do
        # Expect the response to have HTTP status 422 (Unprocessable Entity)
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for DELETE /api/v1/admin/permissions/:id
  describe 'DELETE /api/v1/admin/permissions/:id' do
    let!(:permission) { create(:permission) }

    context 'when the record exists' do
      before { delete "/api/v1/admin/permissions/#{permission.id}", headers: auth_headers }

      it 'deletes the record' do
        # Expect the response to have HTTP status 204 (No Content)
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exist' do
      before { delete '/api/v1/admin/permissions/invalid', headers: auth_headers }

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

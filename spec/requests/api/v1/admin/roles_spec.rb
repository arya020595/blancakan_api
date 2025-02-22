require 'rails_helper'

RSpec.describe 'Roles API', type: :request do
  # Create a role with the name 'superadmin'
  let(:role) { create(:role, name: 'superadmin') }

  # Create a user with the 'superadmin' role
  let(:user) { create(:user, role: role) }

  # Generate authentication headers for the created user
  let(:auth_headers) { user.create_new_auth_token }

  # Test suite for GET /api/v1/admin/roles
  describe 'GET /api/v1/admin/roles' do
    before do
      create_list(:role, 2)
      get '/api/v1/admin/roles', headers: auth_headers
    end

    it 'returns all roles' do
      expect(response).to have_http_status(200)
      expect(json['data'].size).to eq(3) # Including the initial 'superadmin' role
    end
  end

  # Test suite for POST /api/v1/admin/roles
  describe 'POST /api/v1/admin/roles' do
    let(:valid_attributes) { { role: { name: 'admin', description: 'Administrator role' } } }

    context 'when the request is valid' do
      before { post '/api/v1/admin/roles', params: valid_attributes, headers: auth_headers }

      it 'creates a role' do
        expect(response).to have_http_status(201)
        expect(json['data']['name']).to eq('admin')
      end
    end

    context 'when the request is invalid' do
      before { post '/api/v1/admin/roles', params: { role: { name: '', description: '' } }, headers: auth_headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for GET /api/v1/admin/roles/:id
  describe 'GET /api/v1/admin/roles/:id' do
    let(:role1) { create(:role) }

    context 'when the record exists' do
      before { get "/api/v1/admin/roles/#{role.id}", headers: auth_headers }

      it 'returns the role' do
        expect(response).to have_http_status(200)
        expect(json['data']['_id']).to eq(role.id.to_s)
      end
    end

    context 'when the record does not exist' do
      before { get '/api/v1/admin/roles/invalid', headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for PUT /api/v1/admin/roles/:id
  describe 'PUT /api/v1/admin/roles/:id' do
    let(:role1) { create(:role) }
    let(:valid_attributes) { { role: { name: 'superadmin', description: 'Super Administrator role' } } }

    context 'when the record exists' do
      before { put "/api/v1/admin/roles/#{role.id}", params: valid_attributes, headers: auth_headers }

      it 'updates the record' do
        expect(response).to have_http_status(200)
        expect(role.reload.name).to eq('superadmin')
      end
    end

    context 'when the request is invalid' do
      before do
        put "/api/v1/admin/roles/#{role.id}", params: { role: { name: '', description: '' } }, headers: auth_headers
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Test suite for DELETE /api/v1/admin/roles/:id
  describe 'DELETE /api/v1/admin/roles/:id' do
    let!(:role1) { create(:role) }

    context 'when the record exists' do
      before { delete "/api/v1/admin/roles/#{role.id}", headers: auth_headers }

      it 'deletes the record' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exist' do
      before { delete '/api/v1/admin/roles/invalid', headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end
end

# Helper method to parse JSON responses
def json
  JSON.parse(response.body)
end

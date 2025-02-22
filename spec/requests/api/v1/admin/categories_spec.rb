require 'rails_helper'

RSpec.describe 'Categories API', type: :request do
  let(:role) { create(:role, name: 'superadmin') }
  let(:user) { create(:user, role: role) }
  let(:auth_headers) { user.create_new_auth_token }

  describe 'GET /api/v1/admin/categories' do
    before do
      create_list(:category, 2)
      get '/api/v1/admin/categories', headers: auth_headers
    end

    it 'returns all categories' do
      expect(response).to have_http_status(200)
      expect(json['data'].size).to eq(2)
    end
  end

  describe 'POST /api/v1/admin/categories' do
    let(:valid_attributes) do
      {
        category: {
          name: 'Tech',
          description: 'Technology related events'
        }
      }
    end

    context 'when the request is valid' do
      before { post '/api/v1/admin/categories', params: valid_attributes, headers: auth_headers }

      it 'creates a category' do
        expect(response).to have_http_status(201)
        expect(json['data']['name']).to eq('Tech')
      end
    end

    context 'when the request is invalid' do
      before do
        post '/api/v1/admin/categories',
             params: { category: { name: '', description: '' } }, headers: auth_headers
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'GET /api/v1/admin/categories/:id' do
    let(:category) { create(:category) }

    context 'when the record exists' do
      before { get "/api/v1/admin/categories/#{category.id}", headers: auth_headers }

      it 'returns the category' do
        expect(response).to have_http_status(200)
        expect(json['data']['_id']).to eq(category.id.to_s)
      end
    end

    context 'when the record does not exist' do
      before { get '/api/v1/admin/categories/invalid', headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'PUT /api/v1/admin/categories/:id' do
    let(:category) { create(:category) }
    let(:valid_attributes) do
      { category: { name: 'Updated Category', description: 'Updated description' } }
    end

    context 'when the record exists' do
      before { put "/api/v1/admin/categories/#{category.id}", params: valid_attributes, headers: auth_headers }

      it 'updates the record' do
        expect(response).to have_http_status(200)
        expect(category.reload.name).to eq('Updated Category')
      end
    end

    context 'when the request is invalid' do
      before do
        put "/api/v1/admin/categories/#{category.id}", params: { category: { name: '', description: '' } },
                                                       headers: auth_headers
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/v1/admin/categories/:id' do
    let!(:category) { create(:category) }

    context 'when the record exists' do
      before { delete "/api/v1/admin/categories/#{category.id}", headers: auth_headers }

      it 'deletes the record' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exist' do
      before { delete '/api/v1/admin/categories/invalid', headers: auth_headers }

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

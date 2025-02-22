require 'rails_helper'

RSpec.describe 'Events API', type: :request do
  let(:role) { create(:role, name: 'superadmin') }
  let(:user) { create(:user, role: role) }
  let(:category) { create(:category, name: 'test category') }
  let(:auth_headers) { user.create_new_auth_token }

  describe 'GET /api/v1/admin/events' do
    before do
      create_list(:event, 2)
      get '/api/v1/admin/events', headers: auth_headers
    end

    it 'returns all events' do
      expect(response).to have_http_status(200)
      expect(json['data'].size).to eq(2)
    end
  end

  describe 'POST /api/v1/admin/events' do
    let(:valid_attributes) do
      {
        event: {
          title: 'Tech Conference 2025',
          description: 'A conference about emerging technologies.',
          location: 'Jakarta Convention Center',
          starts_at: '2025-03-10T09:00:00Z',
          ends_at: '2025-03-10T17:00:00Z',
          organizer: 'Tech Community',
          status: 'draft',
          category_id: category.id,
          user_id: user.id
        }
      }
    end

    context 'when the request is valid' do
      before { post '/api/v1/admin/events', params: valid_attributes, headers: auth_headers }

      it 'creates an event' do
        expect(response).to have_http_status(201)
        expect(json['data']['title']).to eq('Tech Conference 2025')
      end
    end

    context 'when the request is invalid' do
      before do
        post '/api/v1/admin/events',
             params: { event: { title: '', description: '', date: '' } }, headers: auth_headers
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'GET /api/v1/admin/events/:id' do
    let(:event) { create(:event) }

    context 'when the record exists' do
      before { get "/api/v1/admin/events/#{event.id}", headers: auth_headers }

      it 'returns the event' do
        expect(response).to have_http_status(200)
        expect(json['data']['_id']).to eq(event.id.to_s)
      end
    end

    context 'when the record does not exist' do
      before { get '/api/v1/admin/events/invalid', headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'PUT /api/v1/admin/events/:id' do
    let(:event) { create(:event) }
    let(:valid_attributes) do
      { event: { title: 'Updated Event', description: 'Updated description', date: '2025-02-23' } }
    end

    context 'when the record exists' do
      before { put "/api/v1/admin/events/#{event.id}", params: valid_attributes, headers: auth_headers }

      it 'updates the record' do
        expect(response).to have_http_status(200)
        expect(event.reload.title).to eq('Updated Event')
      end
    end

    context 'when the request is invalid' do
      before do
        put "/api/v1/admin/events/#{event.id}", params: { event: { title: '', description: '', date: '' } },
                                                headers: auth_headers
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /api/v1/admin/events/:id' do
    let!(:event) { create(:event) }

    context 'when the record exists' do
      before { delete "/api/v1/admin/events/#{event.id}", headers: auth_headers }

      it 'deletes the record' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exist' do
      before { delete '/api/v1/admin/events/invalid', headers: auth_headers }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end
end

def json
  JSON.parse(response.body)
end

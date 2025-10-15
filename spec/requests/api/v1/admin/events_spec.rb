require 'swagger_helper'

RSpec.describe 'Events API', type: :request do
  # Setup user and authentication headers
  let(:role) { create(:role, name: 'superadmin') }
  let(:user) { create(:user, role: role) }
  let(:category) { create(:category, name: 'test category') }
  let(:auth_headers) { user.create_new_auth_token }
  let(:Authorization) { "Bearer #{auth_headers['Authorization']}" }

  # Define the path for retrieving all events
  path '/api/v1/admin/events' do
    get 'Retrieves all events' do
      tags 'Events'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'events found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       _id: { type: :string },
                       title: { type: :string },
                       description: { type: :string },
                       location: { type: :string },
                       starts_at: { type: :string, format: :date_time },
                       ends_at: { type: :string, format: :date_time },
                       organizer: { type: :string },
                       status: { type: :string },
                       category_id: { type: :string },
                       user_id: { type: :string },
                       created_at: { type: :string, format: :date_time },
                       updated_at: { type: :string, format: :date_time }
                     },
                     required: %w[_id title description location starts_at ends_at organizer status category_id user_id
                                  created_at updated_at]
                   }
                 }
               },
               required: %w[status message data]

        before do
          create_list(:event, 2, starts_at: 1.day.from_now, ends_at: 2.days.from_now)
        end

        run_test!
      end
    end

    # Define the path for creating a new event
    post 'Creates an event' do
      tags 'Events'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          location: { type: :string },
          starts_at: { type: :string, format: :date_time },
          ends_at: { type: :string, format: :date_time },
          organizer: { type: :string },
          status: { type: :string },
          category_id: { type: :string },
          user_id: { type: :string }
        },
        required: %w[title description location starts_at ends_at organizer status category_id user_id]
      }

      response '201', 'event created' do
        let(:event) do
          { title: 'Tech Conference 2025', description: 'A conference about emerging technologies.',
            location: 'Jakarta Convention Center', starts_at: '2025-03-10T09:00:00Z', ends_at: '2025-03-10T17:00:00Z', organizer: 'Tech Community', status: 'draft', category_id: category.id, user_id: user.id }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:event) do
          { title: '', description: '', location: '', starts_at: '', ends_at: '', organizer: '', status: '', category_id: '',
            user_id: '' }
        end
        run_test!
      end
    end
  end

  # Define the path for retrieving a specific event by ID
  path '/api/v1/admin/events/{id}' do
    get 'Retrieves an event' do
      tags 'Events'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'event found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     _id: { type: :string },
                     title: { type: :string },
                     description: { type: :string },
                     location: { type: :string },
                     starts_at: { type: :string, format: :date_time },
                     ends_at: { type: :string, format: :date_time },
                     organizer: { type: :string },
                     status: { type: :string },
                     category_id: { type: :string },
                     user_id: { type: :string },
                     created_at: { type: :string, format: :date_time },
                     updated_at: { type: :string, format: :date_time }
                   },
                   required: %w[_id title description location starts_at ends_at organizer status category_id user_id
                                created_at updated_at]
                 }
               },
               required: %w[status message data]

        let(:id) do
          Event.create(title: 'Tech Conference 2025', description: 'A conference about emerging technologies.',
                       location: 'Jakarta Convention Center', starts_at: '2025-03-10T09:00:00Z', ends_at: '2025-03-10T17:00:00Z', organizer: 'Tech Community', status: 'draft', category_id: category.id, user_id: user.id).id
        end
        run_test!
      end

      response '404', 'event not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    # Define the path for updating a specific event by ID
    put 'Updates an event' do
      tags 'Events'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          location: { type: :string },
          starts_at: { type: :string, format: :date_time },
          ends_at: { type: :string, format: :date_time },
          organizer: { type: :string },
          status: { type: :string },
          category_id: { type: :string },
          user_id: { type: :string }
        },
        required: %w[title description location starts_at ends_at organizer status category_id user_id]
      }

      response '200', 'event updated' do
        let(:id) do
          Event.create(title: 'Tech Conference 2025', description: 'A conference about emerging technologies.',
                       location: 'Jakarta Convention Center', starts_at: '2025-03-10T09:00:00Z', ends_at: '2025-03-10T17:00:00Z', organizer: 'Tech Community', status: 'draft', category_id: category.id, user_id: user.id).id
        end
        let(:event) do
          { title: 'Updated Event', description: 'Updated description', location: 'Updated location',
            starts_at: '2025-03-10T09:00:00Z', ends_at: '2025-03-10T17:00:00Z', organizer: 'Updated Organizer', status: 'published', category_id: category.id, user_id: user.id }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) do
          Event.create(title: 'Tech Conference 2025', description: 'A conference about emerging technologies.',
                       location: 'Jakarta Convention Center', starts_at: '2025-03-10T09:00:00Z', ends_at: '2025-03-10T17:00:00Z', organizer: 'Tech Community', status: 'draft', category_id: category.id, user_id: user.id).id
        end
        let(:event) do
          { title: '', description: '', location: '', starts_at: '', ends_at: '', organizer: '', status: '', category_id: '',
            user_id: '' }
        end
        run_test!
      end
    end

    # Define the path for deleting a specific event by ID
    delete 'Deletes an event' do
      tags 'Events'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'event deleted' do
        let(:id) do
          Event.create(title: 'Tech Conference 2025', description: 'A conference about emerging technologies.',
                       location: 'Jakarta Convention Center', starts_at: '2025-03-10T09:00:00Z', ends_at: '2025-03-10T17:00:00Z', organizer: 'Tech Community', status: 'draft', category_id: category.id, user_id: user.id).id
        end
        run_test!
      end

      response '404', 'event not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end

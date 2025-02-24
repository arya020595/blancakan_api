require 'swagger_helper'

RSpec.describe 'Categories API', type: :request do
  # Setup user and authentication headers
  let(:role) { create(:role, name: 'superadmin') }
  let(:user) { create(:user, role: role) }
  let(:auth_headers) { user.create_new_auth_token }
  let(:Authorization) { "Bearer #{auth_headers['Authorization']}" }

  # Define the path for retrieving all categories
  path '/api/v1/admin/categories' do
    get 'Retrieves all categories' do
      tags 'Categories'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'categories found' do
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
                       name: { type: :string },
                       description: { type: :string },
                       parent_id: { type: :string, nullable: true },
                       status: { type: :boolean },
                       created_at: { type: :string, format: :date_time },
                       updated_at: { type: :string, format: :date_time }
                     },
                     required: %w[_id name description status created_at updated_at]
                   }
                 }
               },
               required: %w[status message data]

        before do
          create_list(:category, 2)
        end

        run_test!
      end
    end

    # Define the path for creating a new category
    post 'Creates a category' do
      tags 'Categories'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string }
        },
        required: %w[name description]
      }

      response '201', 'category created' do
        let(:category) { { name: 'Tech', description: 'Technology related events' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:category) { { name: '', description: '' } }
        run_test!
      end
    end
  end

  # Define the path for retrieving a specific category by ID
  path '/api/v1/admin/categories/{id}' do
    get 'Retrieves a category' do
      tags 'Categories'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'category found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     _id: { type: :string },
                     name: { type: :string },
                     description: { type: :string },
                     parent_id: { type: :string, nullable: true },
                     status: { type: :boolean },
                     created_at: { type: :string, format: :date_time },
                     updated_at: { type: :string, format: :date_time }
                   },
                   required: %w[_id name description status created_at updated_at]
                 }
               },
               required: %w[status message data]

        let(:id) { Category.create(name: 'Tech', description: 'Technology related events').id }
        run_test!
      end

      response '404', 'category not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    # Define the path for updating a specific category by ID
    put 'Updates a category' do
      tags 'Categories'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string }
        },
        required: %w[name description]
      }

      response '200', 'category updated' do
        let(:id) { Category.create(name: 'Tech', description: 'Technology related events').id }
        let(:category) { { name: 'Updated Category', description: 'Updated description' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Category.create(name: 'Tech', description: 'Technology related events').id }
        let(:category) { { name: '', description: '' } }
        run_test!
      end
    end

    # Define the path for deleting a specific category by ID
    delete 'Deletes a category' do
      tags 'Categories'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'category deleted' do
        let(:id) { Category.create(name: 'Tech', description: 'Technology related events').id }
        run_test!
      end

      response '404', 'category not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end

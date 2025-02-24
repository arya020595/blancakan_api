require 'swagger_helper'

RSpec.describe 'Roles API', type: :request do
  # Create a role with the name 'superadmin' for generate auth_headers purpose only
  let(:init_role) { create(:role, name: 'superadmin') }

  # Create a user with the 'superadmin' role
  let(:user) { create(:user, role: init_role) }

  # Generate authentication headers for the created user
  let(:auth_headers) { user.create_new_auth_token }
  let(:Authorization) { "Bearer #{auth_headers['Authorization']}" }

  # Define the path for retrieving all roles
  path '/api/v1/admin/roles' do
    get 'Retrieves all roles' do
      tags 'Roles'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'roles found' do
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
                       created_at: { type: :string, format: :date_time },
                       updated_at: { type: :string, format: :date_time }
                     },
                     required: %w[_id name created_at updated_at]
                   }
                 }
               },
               required: %w[status message data]

        before do
          create_list(:role, 2)
        end

        run_test!
      end
    end

    post 'Creates a role' do
      tags 'Roles'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :role, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string }
        },
        required: %w[name description]
      }

      response '201', 'role created' do
        let(:role) { { name: 'manager', description: 'Manager role' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:role) { { name: '', description: '' } }
        run_test!
      end
    end
  end

  # Define the path for retrieving a specific role by ID
  path '/api/v1/admin/roles/{id}' do
    get 'Retrieves a role' do
      tags 'Roles'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'role found' do
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
                     created_at: { type: :string, format: :date_time },
                     updated_at: { type: :string, format: :date_time }
                   },
                   required: %w[_id name description created_at updated_at]
                 }
               },
               required: %w[status message data]

        let(:id) { Role.create(name: 'admin', description: 'Administrator role').id }
        run_test!
      end

      response '404', 'role not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Updates a role' do
      tags 'Roles'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :role, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string }
        },
        required: %w[name description]
      }

      response '200', 'role updated' do
        let(:id) { Role.create(name: 'unique_admin', description: 'Administrator role').id }
        let(:role) { { name: 'unique_superadmin', description: 'Super Administrator role' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Role.create(name: 'another_admin', description: 'Administrator role').id }
        let(:role) { { name: '', description: '' } }
        run_test!
      end
    end

    delete 'Deletes a role' do
      tags 'Roles'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'role deleted' do
        let(:id) { Role.create(name: 'admin', description: 'Administrator role').id }
        run_test!
      end

      response '404', 'role not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end

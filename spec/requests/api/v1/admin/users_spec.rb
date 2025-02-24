require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  # Create a role with the name 'superadmin' for generate auth_headers purpose only
  let(:init_role) { create(:role, name: 'superadmin') }

  # Create a user with the 'superadmin' role
  let(:init_user) { create(:user, role: init_role) }

  # Generate authentication headers for the created user
  let(:auth_headers) { init_user.create_new_auth_token }
  let(:Authorization) { "Bearer #{auth_headers['Authorization']}" }

  # Define the path for retrieving all users
  path '/api/v1/admin/users' do
    get 'Retrieves all users' do
      tags 'Users'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'users found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string },
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       name: { type: :string },
                       email: { type: :string },
                       role_id: { type: :string },
                       created_at: { type: :string, format: :date_time },
                       updated_at: { type: :string, format: :date_time }
                     },
                     required: %w[id name email role_id created_at updated_at]
                   }
                 }
               },
               required: %w[status message data]

        before do
          create_list(:user, 2)
        end

        run_test!
      end
    end

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string },
          role_id: { type: :string }
        },
        required: %w[name email password password_confirmation role_id]
      }

      response '201', 'user created' do
        let(:role) { create(:role) }

        let(:user) do
          {
            user: {
              name: 'John Doe',
              email: 'john.doe@example.com',
              password: 'password',
              password_confirmation: 'password',
              role_id: role.id
            }
          }
        end

        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { name: '', email: '', password: '', password_confirmation: '', role_id: '' } }
        run_test!
      end
    end
  end

  # Define the path for retrieving a specific user by ID
  path '/api/v1/admin/users/{id}' do
    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'user found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     name: { type: :string },
                     email: { type: :string },
                     role_id: { type: :string },
                     created_at: { type: :string, format: :date_time },
                     updated_at: { type: :string, format: :date_time }
                   },
                   required: %w[id name email role_id created_at updated_at]
                 }
               },
               required: %w[status message data]

        let(:user1) { create(:user) }
        let(:id) { user1.id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Updates a user' do
      tags 'Users'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string },
          role_id: { type: :string }
        },
        required: %w[name email password password_confirmation role_id]
      }

      response '200', 'user updated' do
        let(:user1) { create(:user) }
        let(:role) { create(:role) }
        let(:id) { user1.id }
        let(:user) do
          { name: 'Updated Name', email: 'updated.email@example.com', password: 'newpassword',
            password_confirmation: 'newpassword', role_id: role.id }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:user1) { create(:user) }
        let(:id) { user1.id }
        let(:user) { { name: '', email: '', password: '', password_confirmation: '', role_id: '' } }
        run_test!
      end
    end

    delete 'Deletes a user' do
      tags 'Users'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'user deleted' do
        let!(:user1) { create(:user) }
        let(:id) { user1.id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end

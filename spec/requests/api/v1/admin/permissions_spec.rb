require 'swagger_helper'

RSpec.describe 'Permissions API', type: :request do
  # Create a role with the name 'superadmin'
  let(:role) { create(:role, name: 'superadmin') }

  # Create a user with the 'superadmin' role
  let(:user) { create(:user, role: role) }

  # Generate authentication headers for the created user
  let(:auth_headers) { user.create_new_auth_token }
  let(:Authorization) { "Bearer #{auth_headers['Authorization']}" }

  # Define the path for retrieving all permissions
  path '/api/v1/admin/permissions' do
    get 'Retrieves all permissions' do
      tags 'Permissions'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'permissions found' do
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
                       action: { type: :string },
                       subject_class: { type: :string },
                       role_id: { type: :string },
                       created_at: { type: :string, format: :date_time },
                       updated_at: { type: :string, format: :date_time }
                     },
                     required: %w[_id action subject_class role_id created_at updated_at]
                   }
                 }
               },
               required: %w[status message data]

        before do
          create_list(:permission, 2)
        end

        run_test!
      end
    end

    post 'Creates a permission' do
      tags 'Permissions'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :permission, in: :body, schema: {
        type: :object,
        properties: {
          action: { type: :string },
          subject_class: { type: :string },
          role_id: { type: :string }
        },
        required: %w[action subject_class role_id]
      }

      response '201', 'permission created' do
        let(:permission) { { action: 'read', subject_class: 'User', role_id: role.id } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:permission) { { action: '', subject_class: '', role_id: '' } }
        run_test!
      end
    end
  end

  # Define the path for retrieving a specific permission by ID
  path '/api/v1/admin/permissions/{id}' do
    get 'Retrieves a permission' do
      tags 'Permissions'
      produces 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'permission found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 message: { type: :string },
                 data: {
                   type: :object,
                   properties: {
                     _id: { type: :string },
                     action: { type: :string },
                     subject_class: { type: :string },
                     role_id: { type: :string },
                     created_at: { type: :string, format: :date_time },
                     updated_at: { type: :string, format: :date_time }
                   },
                   required: %w[_id action subject_class role_id created_at updated_at]
                 }
               },
               required: %w[status message data]

        let(:id) { Permission.create(action: 'read', subject_class: 'User', role_id: role.id).id }
        run_test!
      end

      response '404', 'permission not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Updates a permission' do
      tags 'Permissions'
      consumes 'application/json'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :permission, in: :body, schema: {
        type: :object,
        properties: {
          action: { type: :string },
          subject_class: { type: :string },
          role_id: { type: :string }
        },
        required: %w[action subject_class role_id]
      }

      response '200', 'permission updated' do
        let(:id) { Permission.create(action: 'read', subject_class: 'User', role_id: role.id).id }
        let(:permission) { { action: 'manage', subject_class: 'User', role_id: role.id } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { Permission.create(action: 'read', subject_class: 'User', role_id: role.id).id }
        let(:permission) { { action: '', subject_class: '', role_id: '' } }
        run_test!
      end
    end

    delete 'Deletes a permission' do
      tags 'Permissions'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'permission deleted' do
        let(:id) { Permission.create(action: 'read', subject_class: 'User', role_id: role.id).id }
        run_test!
      end

      response '404', 'permission not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end

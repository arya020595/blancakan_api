require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/auth' do
    post 'Registers a new user' do
      tags 'Authentication'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: %w[email password password_confirmation]
      }

      response '200', 'user registered' do
        let(:user) { { email: 'test@example.com', password: 'password', password_confirmation: 'password' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['email']).to eq('test@example.com')
        end
      end

      response '422', 'invalid request' do
        let(:user) { { email: 'test@example.com', password: 'password', password_confirmation: 'mismatch' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
        end
      end
    end
  end

  path '/auth/sign_in' do
    post 'Signs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      response '200', 'user signed in' do
        let!(:user) { create(:user, email: 'test@example.com', password: 'password') }
        let(:credentials) { { email: 'test@example.com', password: 'password' } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'test@example.com', password: 'wrongpassword' } }
        run_test!
      end
    end
  end

  path '/auth/sign_out' do
    delete 'Signs out a user' do
      tags 'Authentication'
      security [bearerAuth: []]

      response '200', 'user signed out' do
        let(:user) { create(:user, email: 'test@example.com', password: 'password') }
        let(:auth_headers) { user.create_new_auth_token }
        let(:Authorization) { "Bearer #{auth_headers['Authorization']}" }
        run_test!
      end
    end
  end
end

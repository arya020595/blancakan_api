require 'rails_helper'

RSpec.describe "Api::V1::Admin::Roles", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/admin/roles/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/admin/roles/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/admin/roles/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/api/v1/admin/roles/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/admin/roles/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end

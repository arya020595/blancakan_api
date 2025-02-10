require 'rails_helper'

RSpec.describe "Api::V1::Admin::Permissions", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/admin/permissions/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/admin/permissions/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/admin/permissions/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/api/v1/admin/permissions/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/admin/permissions/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end

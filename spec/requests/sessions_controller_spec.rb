require "rails_helper"

RSpec.describe SessionsController, type: :request do
  describe "#create" do
    it "signs in with valid credentials" do
      sys_manager = create(:sys_manager, password: "secret123")

      post session_path, params: { email_address: sys_manager.email_address, password: "secret123" }

      expect(response).to redirect_to(root_url)
    end

    it "rejects invalid credentials" do
      sys_manager = create(:sys_manager, password: "secret123")

      post session_path, params: { email_address: sys_manager.email_address, password: "wrong" }

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#destroy" do
    it "signs out" do
      sign_in

      delete session_path

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "protected management area" do
    it "redirects to the login page when not authenticated" do
      get events_path

      expect(response).to redirect_to(new_session_path)
    end
  end
end

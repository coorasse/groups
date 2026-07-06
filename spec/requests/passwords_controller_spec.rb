require "rails_helper"

RSpec.describe PasswordsController, type: :request do
  describe "#new" do
    it "renders the reset request form" do
      get new_password_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "sends the reset instructions to an existing manager" do
      sys_manager = create(:sys_manager)

      expect { post passwords_path, params: { email_address: sys_manager.email_address } }
        .to have_enqueued_mail(PasswordsMailer, :reset)

      expect(response).to redirect_to(new_session_path)
    end

    it "does not reveal whether the email exists" do
      expect { post passwords_path, params: { email_address: "sconosciuto@example.com" } }
        .not_to have_enqueued_mail(PasswordsMailer, :reset)

      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "#edit" do
    it "renders the new password form with a valid token" do
      sys_manager = create(:sys_manager)

      get edit_password_path(sys_manager.password_reset_token)

      expect(response).to have_http_status(:ok)
    end

    it "rejects an invalid token" do
      get edit_password_path("token-non-valido")

      expect(response).to redirect_to(new_password_path)
    end
  end

  describe "#update" do
    it "resets the password and terminates the open sessions" do
      sys_manager = create(:sys_manager)
      sys_manager.sessions.create!

      patch password_path(sys_manager.password_reset_token),
        params: { password: "nuova-password", password_confirmation: "nuova-password" }

      expect(response).to redirect_to(new_session_path)
      expect(sys_manager.sessions.reload).to be_empty
      expect(sys_manager.reload.authenticate("nuova-password")).to be_truthy
    end

    it "rejects a mismatched confirmation" do
      sys_manager = create(:sys_manager)
      token = sys_manager.password_reset_token

      patch password_path(token),
        params: { password: "nuova-password", password_confirmation: "diversa" }

      expect(response).to redirect_to(edit_password_path(token))
      expect(sys_manager.reload.authenticate("password")).to be_truthy
    end
  end
end

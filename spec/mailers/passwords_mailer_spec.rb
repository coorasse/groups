require "rails_helper"

RSpec.describe PasswordsMailer do
  describe "#reset" do
    it "sends the reset link to the manager" do
      sys_manager = create(:sys_manager)

      mail = described_class.reset(sys_manager)

      expect(mail.to).to eq([ sys_manager.email_address ])
      expect(mail.subject).to eq("Reset your password")
      expect(mail.body.encoded).to include("/passwords/")
    end
  end
end

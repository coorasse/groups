require "rails_helper"

RSpec.describe SysManager do
  it "has a valid factory" do
    expect(build(:sys_manager)).to be_valid
  end

  it "authenticates with the correct password" do
    sys_manager = create(:sys_manager, password: "secret123")

    expect(SysManager.authenticate_by(email_address: sys_manager.email_address, password: "secret123")).to eq(sys_manager)
  end

  it "normalizes the email address" do
    sys_manager = create(:sys_manager, email_address: "  Mixed@Example.COM ")

    expect(sys_manager.email_address).to eq("mixed@example.com")
  end
end

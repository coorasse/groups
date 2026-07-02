module AuthenticationHelpers
  def sign_in(sys_manager = create(:sys_manager), password: "password")
    post session_path, params: { email_address: sys_manager.email_address, password: password }
    sys_manager
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end

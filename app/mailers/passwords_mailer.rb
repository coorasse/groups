class PasswordsMailer < ApplicationMailer
  def reset(sys_manager)
    @sys_manager = sys_manager
    mail subject: "Reset your password", to: sys_manager.email_address
  end
end

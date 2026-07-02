class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_sys_manager_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: t("passwords.create.rate_limited") }

  def new
  end

  def create
    if sys_manager = SysManager.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(sys_manager).deliver_later
    end

    redirect_to new_session_path, notice: t("passwords.create.sent")
  end

  def edit
  end

  def update
    if @sys_manager.update(params.permit(:password, :password_confirmation))
      @sys_manager.sessions.destroy_all
      redirect_to new_session_path, notice: t("passwords.update.reset")
    else
      redirect_to edit_password_path(params[:token]), alert: t("passwords.update.mismatch")
    end
  end

  private
    def set_sys_manager_by_token
      @sys_manager = SysManager.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t("passwords.invalid_token")
    end
end

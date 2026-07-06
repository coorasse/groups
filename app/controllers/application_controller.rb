class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_reservation_to_confirm

  private

  # After a reservation is approved, ReservationsController#update stashes its id in the
  # flash so the confirmation reminder modal can render on whichever page the redirect lands on.
  def set_reservation_to_confirm
    return if flash[:reservation_to_confirm_id].blank?

    @reservation_to_confirm = Reservation.find_by(id: flash[:reservation_to_confirm_id])
  end

  # Inline edits (from a table cell) submit `inline=1`. On success/failure they
  # redirect back to the same page so Turbo morphs it, preserving scroll.
  def inline_request?
    params[:inline].present?
  end
end

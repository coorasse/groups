class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Inline edits (from a table cell) submit `inline=1`. On success/failure they
  # redirect back to the same page so Turbo morphs it, preserving scroll.
  def inline_request?
    params[:inline].present?
  end
end

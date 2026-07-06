require "rails_helper"

RSpec.describe Public::Bookings::ConfirmationsController, type: :request do
  let(:same_site_headers) { { "Sec-Fetch-Site" => "same-origin" } }
  let(:group) { create(:group) }

  def confirm(reservation, headers: same_site_headers)
    patch booking_confirmation_path(reservation.token), headers: headers
  end

  describe "#update" do
    it "confirms an approved reservation and redirects to its booking page" do
      reservation = create(:reservation, group: group, status: :approved)

      confirm(reservation)

      expect(reservation.reload).to be_confirmed
      expect(response).to redirect_to(booking_path(reservation.token))
    end

    it "does not change the status of a reservation that is not approved" do
      reservation = create(:reservation, group: group, status: :requested)

      confirm(reservation)

      expect(reservation.reload).to be_requested
      expect(response).to redirect_to(booking_path(reservation.token))
    end

    it "does not set a session cookie" do
      reservation = create(:reservation, group: group, status: :approved)

      confirm(reservation)

      expect(response.headers["Set-Cookie"]).to be_nil
    end

    it "rejects submissions without the Sec-Fetch-Site header" do
      reservation = create(:reservation, group: group, status: :approved)

      confirm(reservation, headers: {})

      expect(reservation.reload).to be_approved
      expect(response).to have_http_status(:forbidden)
    end

    it "rejects cross-site submissions" do
      reservation = create(:reservation, group: group, status: :approved)

      confirm(reservation, headers: { "Sec-Fetch-Site" => "cross-site" })

      expect(reservation.reload).to be_approved
      expect(response).to have_http_status(:forbidden)
    end

    it "returns a 404 for an unknown token" do
      patch booking_confirmation_path("does-not-exist"), headers: same_site_headers

      expect(response).to have_http_status(:not_found)
    end
  end
end

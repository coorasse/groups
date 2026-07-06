require "rails_helper"

RSpec.describe Public::BookingsController, type: :request do
  let(:event) { create(:event, title: "Tour del centro storico") }
  let(:group) { create(:group, event: event, date: Date.new(2026, 7, 10), time: "10:30") }

  describe "#show" do
    it "renders the booking page for a valid token" do
      reservation = create(:reservation, group: group, full_name: "Mario Rossi", status: :requested)

      get booking_path(reservation.token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mario Rossi")
      expect(response.body).to include("Tour del centro storico")
    end

    it "shows the confirm button only when the reservation is approved" do
      reservation = create(:reservation, group: group, status: :approved)

      get booking_path(reservation.token)

      expect(response.body).to include("Conferma la prenotazione")
    end

    it "does not show the confirm button when the reservation is only requested" do
      reservation = create(:reservation, group: group, status: :requested)

      get booking_path(reservation.token)

      expect(response.body).not_to include("Conferma la prenotazione")
    end

    it "shows the success message once confirmed" do
      reservation = create(:reservation, group: group, status: :confirmed)

      get booking_path(reservation.token)

      expect(response.body).to include("prenotazione è confermata")
      expect(response.body).not_to include("Conferma la prenotazione")
    end

    it "does not set a session cookie" do
      reservation = create(:reservation, group: group)

      get booking_path(reservation.token)

      expect(response.headers["Set-Cookie"]).to be_nil
    end

    it "returns a 404 for an unknown token" do
      get booking_path("does-not-exist")

      expect(response).to have_http_status(:not_found)
    end
  end
end

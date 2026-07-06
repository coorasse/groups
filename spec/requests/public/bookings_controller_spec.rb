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

    it "shows the event image and description" do
      event.image.attach(io: File.open(Rails.root.join("spec/fixtures/files/event.png")),
        filename: "event.png", content_type: "image/png")
      event.update!(description: "Un tour indimenticabile nel centro.")
      reservation = create(:reservation, group: group)

      get booking_path(reservation.token)

      expect(response.body).to include("Un tour indimenticabile nel centro.")
      expect(response.body).to include("booking-image")
      expect(response.body).to match(/<img[^>]+event/)
    end

    it "reveals the event instructions only once the reservation is confirmed" do
      event.update!(notes: "Ritrovo davanti alla fontana 15 minuti prima.")
      reservation = create(:reservation, group: group, status: :approved)

      get booking_path(reservation.token)
      expect(response.body).not_to include("Ritrovo davanti alla fontana")

      reservation.confirmed!
      get booking_path(reservation.token)
      expect(response.body).to include("Ritrovo davanti alla fontana")
    end

    it "shows the contact note for corrections" do
      reservation = create(:reservation, group: group)

      get booking_path(reservation.token)

      expect(response.body).to include("tel:+393357501026")
      expect(response.body).to include("mailto:prenota@guidaturisticaromagna.it")
    end

    it "subscribes to the reservation's Turbo stream for live updates" do
      reservation = create(:reservation, group: group)

      get booking_path(reservation.token)

      expect(response.body).to include("turbo-cable-stream-source")
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

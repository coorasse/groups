require "rails_helper"

RSpec.describe Reservations::NotesController, type: :request do
  before { sign_in }

  let(:event) { create(:event) }
  let(:group) { create(:group, event: event) }

  describe "#edit" do
    it "renders the notes modal with the current value" do
      reservation = create(:reservation, group: group, notes: "Allergica alle noci")

      get edit_event_group_reservation_notes_path(event, group, reservation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Allergica alle noci")
      expect(response.body).to include(reservation.full_name)
    end
  end

  describe "#update" do
    it "updates the notes and streams back the refreshed cell" do
      reservation = create(:reservation, group: group)

      patch event_group_reservation_notes_path(event, group, reservation),
        params: { reservation: { notes: "Tavolo vicino alla finestra" } },
        as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(reservation.reload.notes).to eq("Tavolo vicino alla finestra")
      expect(response.body).to include("Tavolo vicino alla finestra")
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "clears the notes when submitted blank" do
      reservation = create(:reservation, group: group, notes: "Da rimuovere")

      patch event_group_reservation_notes_path(event, group, reservation),
        params: { reservation: { notes: "" } },
        as: :turbo_stream

      expect(reservation.reload.notes).to be_blank
    end
  end
end

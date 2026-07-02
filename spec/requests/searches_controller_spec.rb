require "rails_helper"

RSpec.describe SearchesController, type: :request do
  before { sign_in }

  def future_group
    create(:group, date: Date.current + 7, time: "10:00", status: :open)
  end

  def past_group
    create(:group, date: Date.current - 7, time: "10:00", status: :open)
  end

  describe "#reservations" do
    it "finds reservations by name for future events" do
      reservation = create(:reservation, group: future_group, full_name: "Mario Rossi")

      get search_reservations_path, params: { q: "mario" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mario Rossi")
      expect(response.body).to include(reservation.group.event.title)
    end

    it "does not match a different name" do
      create(:reservation, group: future_group, full_name: "Mario Rossi")

      get search_reservations_path, params: { q: "bianchi" }

      expect(response.body).not_to include("Mario Rossi")
    end

    it "excludes reservations for past events by default" do
      create(:reservation, group: past_group, full_name: "Mario Rossi")

      get search_reservations_path, params: { q: "mario" }

      expect(response.body).not_to include("Mario Rossi")
    end

    it "includes reservations for past events when the flag is set" do
      create(:reservation, group: past_group, full_name: "Mario Rossi")

      get search_reservations_path, params: { q: "mario", include_past: "1" }

      expect(response.body).to include("Mario Rossi")
    end

    it "returns no results for a blank query" do
      create(:reservation, group: future_group, full_name: "Mario Rossi")

      get search_reservations_path, params: { q: "" }

      expect(response.body).not_to include("Mario Rossi")
    end

    it "requires authentication" do
      delete session_path

      get search_reservations_path, params: { q: "mario" }

      expect(response).to redirect_to(new_session_path)
    end
  end
end

require "rails_helper"

RSpec.describe ReservationsController, type: :request do
  before { sign_in }

  let(:event) { create(:event, max_group_size: 8) }
  let(:group) { create(:group, event: event) }

  describe "#show" do
    it "renders the reservation" do
      reservation = create(:reservation, group: group)

      get event_group_reservation_path(event, group, reservation)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(reservation.full_name)
    end
  end

  describe "#new" do
    it "renders the form" do
      get new_event_group_reservation_path(event, group)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates a reservation with valid attributes" do
      attributes = { full_name: "Mario Rossi", adults_count: 2, kids_count: 1, guided_tour_only_adults: 0 }

      expect { post event_group_reservations_path(event, group), params: { reservation: attributes } }
        .to change { group.reservations.count }.by(1)

      expect(response).to redirect_to(event_group_path(event, group))
    end

    it "creates admin reservations as confirmed by default" do
      attributes = { full_name: "Mario Rossi", adults_count: 1, kids_count: 0 }

      post event_group_reservations_path(event, group), params: { reservation: attributes }

      expect(group.reservations.last).to be_confirmed
    end

    it "computes the price when left blank" do
      event = create(:event, adult_price: 25, kid_price: 12, adult_guided_tour_price: 5)
      group = create(:group, event: event)
      attributes = { full_name: "Mario Rossi", adults_count: 2, kids_count: 0, guided_tour_only_adults: 0, price_to_pay: "" }

      post event_group_reservations_path(event, group), params: { reservation: attributes }

      expect(group.reservations.last.price_to_pay).to eq(50)
    end

    it "allows overbooking beyond the indicative group capacity" do
      attributes = { full_name: "Mario Rossi", adults_count: 9, kids_count: 0 }

      expect { post event_group_reservations_path(event, group), params: { reservation: attributes } }
        .to change(Reservation, :count).by(1)

      expect(response).to redirect_to(event_group_path(event, group))
    end

    it "re-renders the form with invalid attributes" do
      attributes = { full_name: "", adults_count: 1, kids_count: 0 }

      expect { post event_group_reservations_path(event, group), params: { reservation: attributes } }
        .not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "#update" do
    it "updates the reservation" do
      reservation = create(:reservation, group: group)

      patch event_group_reservation_path(event, group, reservation), params: { reservation: { status: "paid" } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(reservation.reload).to be_paid
    end

    it "can change the status (e.g. confirm a request)" do
      reservation = create(:reservation, group: group, status: :requested)

      patch event_group_reservation_path(event, group, reservation), params: { reservation: { status: "confirmed" } }

      expect(reservation.reload).to be_confirmed
    end

    it "updates a numeric field inline and redirects so Turbo can morph" do
      reservation = create(:reservation, group: group, adults_count: 2)

      patch event_group_reservation_path(event, group, reservation), params: { inline: "1", reservation: { adults_count: 4 } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(reservation.reload.adults_count).to eq(4)
    end

    it "toggles the notified flag inline from the to-notify column" do
      distant_group = create(:group, event: event, date: Date.current + 30)
      reservation = create(:reservation, group: distant_group)

      patch event_group_reservation_path(event, distant_group, reservation),
        params: { inline: "1", reservation: { notified: "1" } }

      expect(reservation.reload).to be_notified
    end

    it "redirects back to the referring page for an inline update, e.g. the events index" do
      reservation = create(:reservation, group: group, status: :requested)

      patch event_group_reservation_path(event, group, reservation),
        params: { inline: "1", reservation: { status: "confirmed" } },
        headers: { "HTTP_REFERER" => events_path }

      expect(response).to redirect_to(events_path)
    end

    it "re-renders the form when a regular edit is invalid" do
      reservation = create(:reservation, group: group)

      patch event_group_reservation_path(event, group, reservation), params: { reservation: { full_name: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(reservation.reload.full_name).to be_present
    end

    it "reverts and redirects with an alert when an inline edit is invalid" do
      reservation = create(:reservation, group: group, adults_count: 2, guided_tour_only_adults: 2)

      patch event_group_reservation_path(event, group, reservation),
        params: { inline: "1", reservation: { adults_count: 1 } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(flash[:alert]).to be_present
      expect(reservation.reload.adults_count).to eq(2)
    end

    it "shows the confirmation reminder modal after confirming a request" do
      reservation = create(:reservation, group: group, status: :requested)

      patch event_group_reservation_path(event, group, reservation), params: { reservation: { status: "confirmed" } }
      follow_redirect!

      expect(response.body).to include(I18n.t("reservations.confirmation_modal.title"))
      expect(response.body).to include(reservation.full_name)
    end

    it "shows the confirmation reminder modal after confirming a request inline" do
      reservation = create(:reservation, group: group, status: :requested)

      patch event_group_reservation_path(event, group, reservation),
        params: { inline: "1", reservation: { status: "confirmed" } }
      follow_redirect!

      expect(response.body).to include(I18n.t("reservations.confirmation_modal.title"))
    end

    it "does not show the confirmation reminder modal for other status changes" do
      reservation = create(:reservation, group: group, status: :confirmed)

      patch event_group_reservation_path(event, group, reservation), params: { reservation: { status: "paid" } }
      follow_redirect!

      expect(response.body).not_to include(I18n.t("reservations.confirmation_modal.title"))
    end
  end

  describe "#destroy" do
    it "deletes the reservation" do
      reservation = create(:reservation, group: group)

      expect { delete event_group_reservation_path(event, group, reservation) }
        .to change(Reservation, :count).by(-1)

      expect(response).to redirect_to(event_group_path(event, group))
    end
  end
end

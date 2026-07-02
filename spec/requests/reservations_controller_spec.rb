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

  describe "#create" do
    it "creates a reservation with valid attributes" do
      attributes = { full_name: "Mario Rossi", adults_count: 2, kids_count: 1, owned_adult_tickets: 0 }

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
      attributes = { full_name: "Mario Rossi", adults_count: 2, kids_count: 0, owned_adult_tickets: 0, price_to_pay: "" }

      post event_group_reservations_path(event, group), params: { reservation: attributes }

      expect(group.reservations.last.price_to_pay).to eq(50)
    end

    it "allows overbooking beyond the indicative group capacity" do
      attributes = { full_name: "Mario Rossi", adults_count: 9, kids_count: 0 }

      expect { post event_group_reservations_path(event, group), params: { reservation: attributes } }
        .to change(Reservation, :count).by(1)

      expect(response).to redirect_to(event_group_path(event, group))
    end
  end

  describe "#update" do
    it "updates the reservation" do
      reservation = create(:reservation, group: group)

      patch event_group_reservation_path(event, group, reservation), params: { reservation: { paid: true } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(reservation.reload).to be_paid
    end

    it "can change the status (e.g. approve a request)" do
      reservation = create(:reservation, group: group, status: :requested)

      patch event_group_reservation_path(event, group, reservation), params: { reservation: { status: "approved" } }

      expect(reservation.reload).to be_approved
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

require "rails_helper"

RSpec.describe Public::ReservationsController, type: :request do
  def bookable_group(**attrs)
    create(:group, { date: Date.current + 7, time: "10:00", status: :open }.merge(attrs))
  end

  describe "#index" do
    it "lists events with open, upcoming groups that have free seats" do
      group = bookable_group

      get public_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(group.event.title)
    end

    it "excludes closed groups" do
      group = bookable_group(status: :closed)

      get public_root_path

      expect(response.body).not_to include(group.event.title)
    end

    it "excludes past groups" do
      group = bookable_group(date: Date.current - 1)

      get public_root_path

      expect(response.body).not_to include(group.event.title)
    end
  end

  describe "#new" do
    it "renders the form for a bookable group" do
      get new_public_group_reservation_path(bookable_group)

      expect(response).to have_http_status(:ok)
    end

    it "redirects when the group is not bookable" do
      get new_public_group_reservation_path(bookable_group(status: :closed))

      expect(response).to redirect_to(public_root_path)
    end
  end

  describe "#create" do
    let(:group) { bookable_group }
    let(:valid_params) do
      {
        full_name: "Mario Rossi", adults_count: 2, kids_count: 1,
        phone: "+39 333 1234567", email: "mario@example.com", data_processing_authorized: "1"
      }
    end

    it "creates the reservation and redirects to the confirmation" do
      expect { post public_group_reservation_path(group), params: { reservation: valid_params } }
        .to change(Reservation, :count).by(1)

      expect(response).to redirect_to(public_confirmation_path)
    end

    it "creates public reservations in the requested status" do
      post public_group_reservation_path(group), params: { reservation: valid_params }

      expect(group.reservations.last).to be_requested
    end

    it "auto-computes the price to pay even though the form never sends it" do
      event = create(:event, adult_price: 25, kid_price: 12)
      group = bookable_group(event: event)
      params = valid_params.merge(adults_count: 2, kids_count: 1)

      post public_group_reservation_path(group), params: { reservation: params }

      # public form has no owned tickets: 2 adults * 25 + 1 kid * 12 = 62
      expect(group.reservations.last.price_to_pay).to eq(62)
    end

    it "ignores owned adult tickets sent by the public form" do
      params = valid_params.merge(owned_adult_tickets: 5)

      post public_group_reservation_path(group), params: { reservation: params }

      expect(group.reservations.last.owned_adult_tickets).to eq(0)
    end

    it "requires the data processing consent" do
      params = valid_params.merge(data_processing_authorized: "0")

      expect { post public_group_reservation_path(group), params: { reservation: params } }
        .not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "requires a phone number" do
      params = valid_params.merge(phone: "")

      expect { post public_group_reservation_path(group), params: { reservation: params } }
        .not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end

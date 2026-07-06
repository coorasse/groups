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

    it "redirects with an unavailable flag when the group is not bookable" do
      get new_public_group_reservation_path(bookable_group(status: :closed))

      expect(response).to redirect_to(public_root_path(unavailable: true))
    end
  end

  describe "#create" do
    # La form pubblica è cookieless: la CSRF protection è basata sull'header
    # Sec-Fetch-Site, che un browser reale invia a ogni submit same-origin.
    let(:same_site_headers) { { "Sec-Fetch-Site" => "same-origin" } }
    let(:group) { bookable_group }
    let(:valid_params) do
      {
        full_name: "Mario Rossi", adults_count: 2, kids_count: 1,
        phone: "+39 333 1234567", email: "mario@example.com", data_processing_authorized: "1"
      }
    end

    def book(params, headers: same_site_headers)
      post public_group_reservation_path(group), params: { reservation: params }, headers: headers
    end

    it "creates the reservation and redirects to its booking page" do
      expect { book(valid_params) }.to change(Reservation, :count).by(1)

      expect(response).to redirect_to(booking_path(Reservation.last.token))
    end

    it "does not set a session cookie" do
      book(valid_params)

      expect(response.headers["Set-Cookie"]).to be_nil
    end

    it "rejects submissions without the Sec-Fetch-Site header" do
      expect { book(valid_params, headers: {}) }.not_to change(Reservation, :count)

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects cross-site submissions" do
      expect { book(valid_params, headers: { "Sec-Fetch-Site" => "cross-site" }) }
        .not_to change(Reservation, :count)

      expect(response).to have_http_status(:forbidden)
    end

    it "creates public reservations in the requested status" do
      book(valid_params)

      expect(group.reservations.last).to be_requested
    end

    it "enqueues the confirmation email when an email was provided" do
      expect { book(valid_params) }.to have_enqueued_mail(ReservationMailer, :confirmation)
    end

    it "does not enqueue a confirmation email when no email was provided" do
      expect { book(valid_params.merge(email: "")) }
        .not_to have_enqueued_mail(ReservationMailer, :confirmation)

      expect(group.reservations.last.email).to be_blank
    end

    it "enqueues the staff notification email for every new request" do
      expect { book(valid_params) }.to have_enqueued_mail(ReservationMailer, :new_request_notification)
    end

    it "enqueues the staff notification email even when no email was provided" do
      expect { book(valid_params.merge(email: "")) }
        .to have_enqueued_mail(ReservationMailer, :new_request_notification)
    end

    it "auto-computes the price to pay even though the form never sends it" do
      event = create(:event, adult_price: 25, kid_price: 12)
      group = bookable_group(event: event)
      params = valid_params.merge(adults_count: 2, kids_count: 1)

      post public_group_reservation_path(group), params: { reservation: params }, headers: same_site_headers

      # public form has no owned tickets: 2 adults * 25 + 1 kid * 12 = 62
      expect(group.reservations.last.price_to_pay).to eq(62)
    end

    it "ignores owned adult tickets sent by the public form" do
      book(valid_params.merge(owned_adult_tickets: 5))

      expect(group.reservations.last.owned_adult_tickets).to eq(0)
    end

    it "requires the data processing consent" do
      expect { book(valid_params.merge(data_processing_authorized: "0")) }
        .not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "requires a phone number" do
      expect { book(valid_params.merge(phone: "")) }.not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "requires at least one adult" do
      expect { book(valid_params.merge(adults_count: 0, kids_count: 1)) }
        .not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects more than 100 adults" do
      expect { book(valid_params.merge(adults_count: 101)) }.not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects more than 100 kids" do
      expect { book(valid_params.merge(kids_count: 101)) }.not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end

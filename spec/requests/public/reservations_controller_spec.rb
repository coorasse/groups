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

    it "excludes groups whose plain seats are full, even with overbooking room left" do
      event = create(:event, max_group_size: 2, max_overbooking: 2)
      group = bookable_group(event: event)
      create(:reservation, group: group, adults_count: 2, kids_count: 0)

      get public_root_path

      expect(response.body).not_to include(group.event.title)
    end

    it "links to the event booking form" do
      group = bookable_group

      get public_root_path

      expect(response.body).to include(new_public_event_reservation_path(group.event))
    end
  end

  describe "#new" do
    it "renders the form for an event with bookable dates" do
      get new_public_event_reservation_path(bookable_group.event)

      expect(response).to have_http_status(:ok)
    end

    it "renders a selectable option for each bookable date of the event" do
      event = create(:event)
      first = bookable_group(event: event, time: "10:00")
      second = bookable_group(event: event, date: Date.current + 9, time: "15:00")

      get new_public_event_reservation_path(event)

      expect(response.body).to include("value=\"#{first.id}\"")
      expect(response.body).to include("value=\"#{second.id}\"")
    end

    it "disables the submit button while the request is in flight" do
      get new_public_event_reservation_path(bookable_group.event)

      expect(response.body).to include('data-turbo-submits-with="Invio in corso')
    end

    it "autofocuses the full name field" do
      get new_public_event_reservation_path(bookable_group.event)

      full_name_field = response.body[/<input[^>]*name="reservation\[full_name\]"[^>]*>/]
      expect(full_name_field).to include("autofocus")
    end

    it "leaves the adults and kids fields empty instead of defaulting to zero" do
      get new_public_event_reservation_path(bookable_group.event)

      adults_field = response.body[/<input[^>]*name="reservation\[adults_count\]"[^>]*>/]
      kids_field = response.body[/<input[^>]*name="reservation\[kids_count\]"[^>]*>/]
      expect(adults_field).not_to include("value=")
      expect(kids_field).not_to include("value=")
    end

    it "asks for confirmation before cancelling the request" do
      get new_public_event_reservation_path(bookable_group.event)

      expect(response.body).to include('data-turbo-confirm=')
      expect(response.body).to include('data-turbo-confirm-accept="Sì, annulla"')
    end

    it "redirects with an unavailable flag when the event has no bookable dates" do
      event = create(:event)
      bookable_group(event: event, status: :closed)

      get new_public_event_reservation_path(event)

      expect(response).to redirect_to(public_root_path(unavailable: true))
    end
  end

  describe "#create" do
    # La form pubblica è cookieless: la CSRF protection è basata sull'header
    # Sec-Fetch-Site, che un browser reale invia a ogni submit same-origin.
    let(:same_site_headers) { { "Sec-Fetch-Site" => "same-origin" } }
    let(:event) { create(:event) }
    let(:group) { bookable_group(event: event) }
    let(:valid_params) do
      {
        full_name: "Mario Rossi", adults_count: 2, kids_count: 1,
        phone: "+39 333 1234567", email: "mario@example.com", data_processing_authorized: "1"
      }
    end

    def book(params, group_id: group.id, headers: same_site_headers)
      post public_event_reservation_path(event),
        params: { reservation: { group_id: group_id, **params } }, headers: headers
    end

    it "creates the reservation for the selected date and redirects to its booking page" do
      expect { book(valid_params) }.to change(Reservation, :count).by(1)

      expect(Reservation.last.group).to eq(group)
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

    it "re-renders the form when no valid date is selected" do
      group # ensure the event still has a bookable date to render

      expect { book(valid_params, group_id: "") }.not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t("activerecord.errors.models.reservation.attributes.base.group_required"))
    end

    it "rejects a date that does not belong to the event" do
      group # the event has its own bookable date
      other = bookable_group(event: create(:event))

      expect { book(valid_params, group_id: other.id) }.not_to change(Reservation, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    context "when the request fits the available seats" do
      it "confirms the reservation automatically" do
        book(valid_params)

        expect(group.reservations.last).to be_confirmed
      end

      it "enqueues the confirmation email to the person who booked" do
        expect { book(valid_params) }.to have_enqueued_mail(ReservationMailer, :approval_confirmation)
      end

      it "does not enqueue the confirmation email when no email was provided" do
        expect { book(valid_params.merge(email: "")) }
          .not_to have_enqueued_mail(ReservationMailer, :approval_confirmation)

        expect(group.reservations.last.email).to be_blank
      end

      it "notifies the operator about the confirmed booking" do
        expect { book(valid_params) }.to have_enqueued_mail(ReservationMailer, :new_booking_notification)
      end
    end

    context "when the request fits only thanks to the overbooking allowance" do
      let(:event) { create(:event, max_group_size: 4, max_overbooking: 5) }
      let(:group) do
        bookable_group(event: event).tap do |g|
          create(:reservation, group: g, adults_count: 3, kids_count: 0)
        end
      end

      it "confirms the reservation automatically" do
        book(valid_params)

        expect(group.reservations.order(:id).last).to be_confirmed
      end

      it "enqueues the confirmation email to the person who booked" do
        expect { book(valid_params) }.to have_enqueued_mail(ReservationMailer, :approval_confirmation)
      end

      it "notifies the operator about the confirmed booking" do
        expect { book(valid_params) }.to have_enqueued_mail(ReservationMailer, :new_booking_notification)
      end
    end

    context "when the request exceeds the seats and the overbooking allowance" do
      let(:event) { create(:event, max_group_size: 4, max_overbooking: 1) }
      let(:group) do
        bookable_group(event: event).tap do |g|
          create(:reservation, group: g, adults_count: 3, kids_count: 0)
        end
      end

      before { group }

      def book_forcing(params)
        post public_event_reservation_path(event),
          params: { reservation: { group_id: group.id, **params }, force_request: "1" },
          headers: same_site_headers
      end

      it "does not create the reservation and re-renders the form with a warning" do
        expect { book(valid_params) }.not_to change(Reservation, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body)
          .to include(I18n.t("activerecord.errors.models.reservation.attributes.base.not_enough_seats"))
      end

      it "still offers the other bookable dates of the event on the re-rendered form" do
        other = bookable_group(event: event, date: Date.current + 9, time: "15:00")

        book(valid_params)

        expect(response.body).to include("value=\"#{other.id}\"")
      end

      it "keeps the reservation in the requested status when the person sends it anyway" do
        book_forcing(valid_params)

        expect(group.reservations.order(:id).last).to be_requested
      end

      it "enqueues the request-received email to the person who booked" do
        expect { book_forcing(valid_params) }.to have_enqueued_mail(ReservationMailer, :confirmation)
      end

      it "does not enqueue the request-received email when no email was provided" do
        expect { book_forcing(valid_params.merge(email: "")) }
          .not_to have_enqueued_mail(ReservationMailer, :confirmation)
      end

      it "notifies the operator about the new request even when no email was provided" do
        expect { book_forcing(valid_params.merge(email: "")) }
          .to have_enqueued_mail(ReservationMailer, :new_request_notification)
      end
    end

    it "auto-computes the price to pay even though the form never sends it" do
      event = create(:event, adult_price: 25, kid_price: 12)
      group = bookable_group(event: event)
      params = { reservation: { group_id: group.id, **valid_params.merge(adults_count: 2, kids_count: 1) } }

      post public_event_reservation_path(event), params: params, headers: same_site_headers

      # public form has no owned tickets: 2 adults * 25 + 1 kid * 12 = 62
      expect(group.reservations.last.price_to_pay).to eq(62)
    end

    it "ignores guided tour only adults sent by the public form" do
      book(valid_params.merge(guided_tour_only_adults: 5))

      expect(group.reservations.last.guided_tour_only_adults).to eq(0)
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

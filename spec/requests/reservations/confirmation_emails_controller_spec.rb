require "rails_helper"

RSpec.describe Reservations::ConfirmationEmailsController, type: :request do
  before { sign_in }

  let(:event) { create(:event) }
  let(:group) { create(:group, event: event) }

  describe "#create" do
    it "delivers the approval confirmation email" do
      reservation = create(:reservation, group: group, email: "mario@example.com", status: :approved)

      expect { post event_group_reservation_confirmation_email_path(event, group, reservation) }
        .to have_enqueued_mail(ReservationMailer, :approval_confirmation).with(reservation)

      expect(response).to redirect_to(event_group_path(event, group))
      follow_redirect!
      expect(response.body).to include("Email di conferma inviata")
    end

    it "does not send an email and shows an alert when the reservation has no email" do
      reservation = create(:reservation, group: group, email: "", status: :approved)

      expect { post event_group_reservation_confirmation_email_path(event, group, reservation) }
        .not_to have_enqueued_mail(ReservationMailer, :approval_confirmation)

      follow_redirect!
      expect(response.body).to include("Questa prenotazione non ha un indirizzo email")
    end
  end
end

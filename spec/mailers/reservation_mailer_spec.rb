require "rails_helper"

RSpec.describe ReservationMailer do
  describe "#confirmation" do
    it "sends a recap to the person who booked" do
      event = create(:event, title: "Tour del centro storico")
      group = create(:group, event: event, date: Date.new(2026, 7, 10), time: "10:30")
      reservation = create(:reservation, group: group, full_name: "Mario Rossi",
        email: "mario@example.com", adults_count: 2, kids_count: 1)

      mail = described_class.confirmation(reservation)

      expect(mail.to).to eq([ "mario@example.com" ])
      expect(mail.subject).to include("Tour del centro storico")
      expect(mail.body.encoded).to include("Mario Rossi")
      expect(mail.body.encoded).to include("Tour del centro storico")
      expect(mail.body.encoded).to include("10:30")
    end

    it "includes a link to the booking status page" do
      reservation = create(:reservation, email: "mario@example.com")

      mail = described_class.confirmation(reservation)

      expect(mail.body.encoded).to include("http://example.com/prenotazione/#{reservation.token}")
    end
  end

  describe "#approval_confirmation" do
    it "sends the event's message template to the person who booked" do
      event = create(:event, title: "Tour del centro storico", message_template: "Ciao <%= nome_completo %>!")
      group = create(:group, event: event)
      reservation = create(:reservation, group: group, full_name: "Mario Rossi", email: "mario@example.com")

      mail = described_class.approval_confirmation(reservation)

      expect(mail.to).to eq([ "mario@example.com" ])
      expect(mail.subject).to include("Tour del centro storico")
      expect(mail.body.encoded).to include("Ciao Mario Rossi!")
    end

    it "interpolates the confirmation link into the message template" do
      event = create(:event, message_template: "Conferma qui: <%= confirmation_link %>")
      group = create(:group, event: event)
      reservation = create(:reservation, group: group, email: "mario@example.com")

      mail = described_class.approval_confirmation(reservation)

      expect(mail.body.encoded).to include("http://example.com/prenotazione/#{reservation.token}")
    end
  end

  describe "#new_request_notification" do
    it "notifies the booking inbox about the new request, with a link to approve it" do
      event = create(:event, title: "Tour del centro storico")
      group = create(:group, event: event, date: Date.new(2026, 7, 10), time: "10:30")
      reservation = create(:reservation, group: group, full_name: "Mario Rossi",
        phone: "+39 333 1234567", email: "mario@example.com", adults_count: 2, kids_count: 1)

      mail = described_class.new_request_notification(reservation)

      expect(mail.to).to eq([ "prenota@guidaturisticaromagna.it" ])
      expect(mail.subject).to include("Tour del centro storico")
      expect(mail.body.encoded).to include("Mario Rossi")
      expect(mail.body.encoded).to include("+39 333 1234567")
      expect(mail.body.encoded).to include("mario@example.com")
      expect(mail.body.encoded).to include("10:30")
      expect(mail.body.encoded).to include("http://example.com/events/#{event.id}/groups/#{group.id}")
    end
  end
end

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
  end
end

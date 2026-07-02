require "rails_helper"

RSpec.describe Reservation do
  it "has a valid factory" do
    expect(build(:reservation)).to be_valid
  end

  it "defaults to the confirmed status" do
    expect(Reservation.new.status).to eq("confirmed")
  end

  describe "public booking context" do
    it "requires the data processing consent" do
      expect(build(:reservation, data_processing_authorized: false).valid?(:public_booking)).to be(false)
    end

    it "requires a phone number" do
      expect(build(:reservation, phone: "", data_processing_authorized: true).valid?(:public_booking)).to be(false)
    end

    it "is valid with consent and phone" do
      expect(build(:reservation, phone: "123", data_processing_authorized: true).valid?(:public_booking)).to be(true)
    end

    it "does not require consent in the default context" do
      expect(build(:reservation, data_processing_authorized: false)).to be_valid
    end
  end

  it "requires a full name" do
    expect(build(:reservation, full_name: nil)).not_to be_valid
  end

  it "is invalid without people" do
    expect(build(:reservation, adults_count: 0, kids_count: 0)).not_to be_valid
  end

  it "rejects more owned tickets than adults" do
    expect(build(:reservation, adults_count: 2, owned_adult_tickets: 3)).not_to be_valid
  end

  it "rejects a malformed email" do
    expect(build(:reservation, email: "not-an-email")).not_to be_valid
  end

  it "allows a blank email" do
    expect(build(:reservation, email: "")).to be_valid
  end

  it "rejects a malformed tax code" do
    expect(build(:reservation, tax_code: "TOO-SHORT")).not_to be_valid
  end

  describe "group capacity (indicative only)" do
    let(:event) { create(:event, max_group_size: 5) }
    let(:group) { create(:group, event: event) }

    it "allows a reservation that exceeds the max group size" do
      expect(build(:reservation, group: group, adults_count: 4, kids_count: 2)).to be_valid
    end

    it "allows overbooking beyond the seats already taken" do
      create(:reservation, group: group, adults_count: 3, kids_count: 0)

      expect(build(:reservation, group: group, adults_count: 2, kids_count: 1)).to be_valid
    end
  end

  describe "#adult_tickets_to_buy" do
    it "is the adults without a ticket, never negative" do
      expect(build(:reservation, adults_count: 3, owned_adult_tickets: 1).adult_tickets_to_buy).to eq(2)
      expect(build(:reservation, adults_count: 2, owned_adult_tickets: 2).adult_tickets_to_buy).to eq(0)
    end
  end

  describe "#computed_price" do
    it "charges full price for tickets to buy, guided tour for owned tickets, full price for kids" do
      event = create(:event, adult_price: 25, kid_price: 12, adult_guided_tour_price: 5)
      group = create(:group, event: event)
      reservation = build(:reservation, group: group, adults_count: 3, owned_adult_tickets: 1, kids_count: 2)

      # 2 tickets to buy * 25 + 1 owned * 5 + 2 kids * 12 = 50 + 5 + 24
      expect(reservation.computed_price).to eq(79)
    end
  end

  describe "price_to_pay" do
    let(:event) { create(:event, adult_price: 25, kid_price: 12, adult_guided_tour_price: 5) }
    let(:group) { create(:group, event: event) }

    it "is filled with the computed price when left blank" do
      reservation = create(:reservation, group: group, adults_count: 2, owned_adult_tickets: 0, kids_count: 0, price_to_pay: nil)

      expect(reservation.price_to_pay).to eq(50)
    end

    it "keeps a manually provided price" do
      reservation = create(:reservation, group: group, adults_count: 2, owned_adult_tickets: 0, kids_count: 0, price_to_pay: 10)

      expect(reservation.price_to_pay).to eq(10)
    end
  end
end

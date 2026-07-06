require "rails_helper"

RSpec.describe Group do
  it "has a valid factory" do
    expect(build(:group)).to be_valid
  end

  it "requires a date" do
    expect(build(:group, date: nil)).not_to be_valid
  end

  it "requires a time" do
    expect(build(:group, time: nil)).not_to be_valid
  end

  it "defaults to the open status" do
    expect(Group.new.status).to eq("open")
  end

  it "is valid without any reservation" do
    expect(build(:group)).to be_valid
  end

  it "allows a blank net price" do
    expect(build(:group, net_price: nil)).to be_valid
  end

  it "rejects a negative net price" do
    expect(build(:group, net_price: -1)).not_to be_valid
  end

  describe "#bookable?" do
    it "is true for an open, upcoming group with free seats" do
      expect(create(:group, date: Date.current + 1, time: "10:00", status: :open)).to be_bookable
    end

    it "is false when closed" do
      expect(create(:group, date: Date.current + 1, time: "10:00", status: :closed)).not_to be_bookable
    end

    it "is false when in the past" do
      expect(create(:group, date: Date.current - 1, time: "10:00", status: :open)).not_to be_bookable
    end

    it "stays bookable while there is overbooking room left" do
      event = create(:event, max_group_size: 2, max_overbooking: 3)
      group = create(:group, event: event, date: Date.current + 1, time: "10:00", status: :open)
      create(:reservation, group: group, adults_count: 3, kids_count: 0)

      expect(group.remaining_seats).to be_negative
      expect(group).to be_bookable
    end

    it "is no longer bookable once the overbooking ceiling is reached" do
      event = create(:event, max_group_size: 2, max_overbooking: 1)
      group = create(:group, event: event, date: Date.current + 1, time: "10:00", status: :open)
      create(:reservation, group: group, adults_count: 3, kids_count: 0)

      expect(group).not_to be_bookable
    end
  end

  describe "capacity inherited from the event and overridable" do
    let(:event) { create(:event, max_group_size: 10, max_overbooking: 2) }

    it "inherits the event capacity when no override is set" do
      group = create(:group, event: event)

      expect(group.effective_max_group_size).to eq(10)
      expect(group.effective_max_overbooking).to eq(2)
      expect(group.total_capacity).to eq(12)
    end

    it "prefers the group override when set" do
      group = create(:group, event: event, max_group_size: 4, max_overbooking: 1)

      expect(group.effective_max_group_size).to eq(4)
      expect(group.effective_max_overbooking).to eq(1)
      expect(group.total_capacity).to eq(5)
    end

    it "counts remaining seats against the effective max group size" do
      group = create(:group, event: event, max_group_size: 4)
      create(:reservation, group: group, adults_count: 3, kids_count: 0)

      expect(group.remaining_seats).to eq(1)
    end

    it "rejects a non-positive max_group_size override" do
      expect(build(:group, max_group_size: 0)).not_to be_valid
    end

    it "rejects a negative max_overbooking override" do
      expect(build(:group, max_overbooking: -1)).not_to be_valid
    end
  end

  describe "#fits_available_seats?" do
    let(:group) { create(:group, event: create(:event, max_group_size: 5, max_overbooking: 3)) }

    it "is true when the people still fit within the plain seats" do
      create(:reservation, group: group, adults_count: 2, kids_count: 0)

      expect(group.fits_available_seats?(3)).to be(true)
    end

    it "is false when the people would spill into the overbooking allowance" do
      create(:reservation, group: group, adults_count: 4, kids_count: 0)

      expect(group.fits_available_seats?(2)).to be(false)
    end
  end

  describe "counts derived from reservations" do
    it "sums the adults, kids and people of its reservations" do
      group = create(:group)
      create(:reservation, group: group, adults_count: 2, kids_count: 1)
      create(:reservation, group: group, adults_count: 1, kids_count: 2)

      expect(group.adults_count).to eq(3)
      expect(group.kids_count).to eq(3)
      expect(group.people_count).to eq(6)
    end
  end

  describe "cancelled reservations" do
    it "excludes cancelled reservations from the people and price aggregates" do
      group = create(:group)
      create(:reservation, group: group, adults_count: 2, kids_count: 1, status: :confirmed, price_to_pay: 50)
      create(:reservation, group: group, adults_count: 5, kids_count: 5, status: :cancelled, price_to_pay: 999)

      expect(group.people_count).to eq(3)
      expect(group.total_price).to eq(50)
    end
  end

  describe "#people_count_for" do
    it "counts people grouped by reservation status" do
      group = create(:group)
      create(:reservation, group: group, adults_count: 2, kids_count: 1, status: :confirmed)
      create(:reservation, group: group, adults_count: 1, kids_count: 0, status: :requested)

      expect(group.people_count_for(:confirmed)).to eq(3)
      expect(group.people_count_for(:requested)).to eq(1)
      expect(group.people_count_for(:approved)).to eq(0)
    end
  end

  describe "pricing" do
    it "sums the computed and effective prices and exposes their difference" do
      group = create(:group)
      create(:reservation, group: group, adults_count: 1, kids_count: 0, owned_adult_tickets: 0, price_to_pay: 100)
      create(:reservation, group: group, adults_count: 1, kids_count: 0, owned_adult_tickets: 0, price_to_pay: nil)

      # each computed = 1 adult ticket to buy * adult_price (20) = 20 -> total computed 40
      expect(group.computed_price).to eq(40)
      expect(group.total_price).to eq(120) # 100 forced + 20 computed
      expect(group.price_difference).to eq(80)
    end
  end
end

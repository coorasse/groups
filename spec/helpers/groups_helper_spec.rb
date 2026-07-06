require "rails_helper"

RSpec.describe GroupsHelper, type: :helper do
  describe "#reservation_image_transition_name" do
    it "builds a unique name from the group id" do
      group = build_stubbed(:group)

      expect(helper.reservation_image_transition_name(group)).to eq("reservation-image-#{group.id}")
    end
  end

  describe "#group_full_datetime" do
    it "renders date and time in full" do
      group = build(:group, date: Date.new(2026, 7, 3), time: "10:30")

      expect(helper.group_full_datetime(group)).to include("ore 10:30")
    end

    it "is blank when the group has no date" do
      group = build(:group, date: nil)

      expect(helper.group_full_datetime(group)).to eq("")
    end
  end
end

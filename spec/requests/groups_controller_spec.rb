require "rails_helper"

RSpec.describe GroupsController, type: :request do
  before { sign_in }

  let(:event) { create(:event, max_group_size: 5) }

  describe "#show" do
    it "renders the group" do
      group = create(:group, event: event)

      get event_group_path(event, group)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.title)
    end
  end

  describe "#create" do
    it "creates a group with valid attributes" do
      attributes = { date: Date.current, time: "10:00", status: "open" }

      expect { post event_groups_path(event), params: { group: attributes } }
        .to change { event.groups.count }.by(1)

      expect(response).to redirect_to(event)
    end

    it "does not create a group without a date" do
      attributes = { date: "", time: "10:00" }

      expect { post event_groups_path(event), params: { group: attributes } }
        .not_to change(Group, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "#update" do
    it "updates the group and stays on the group page" do
      group = create(:group, event: event)

      patch event_group_path(event, group), params: { group: { status: "closed" } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(group.reload).to be_closed
    end

    it "sets the net price inline" do
      group = create(:group, event: event)

      patch event_group_path(event, group), params: { group: { net_price: "42.50" } }

      expect(group.reload.net_price).to eq(42.50)
    end
  end

  describe "#destroy" do
    it "deletes the group" do
      group = create(:group, event: event)

      expect { delete event_group_path(event, group) }.to change(Group, :count).by(-1)

      expect(response).to redirect_to(event)
    end
  end
end

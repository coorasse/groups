require "rails_helper"

RSpec.describe GroupsController, type: :request do
  before { sign_in }

  let(:event) { create(:event, max_group_size: 5) }

  describe "#index" do
    it "lists open groups across events and links to the group page" do
      group = create(:group, event: event, status: :open)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.title)
      expect(response.body).to include(event_group_path(event, group))
    end

    it "uses the event short name when present" do
      event = create(:event, title: "Titolo lungo", short_name: "Breve")
      group = create(:group, event: event, status: :open)

      get root_path

      expect(response.body).to include("Breve")
      expect(response.body).to include(event_group_path(event, group))
    end

    it "omits groups that are not open" do
      closed_group = create(:group, event: event, status: :closed)

      get groups_path

      expect(response.body).not_to include(event_group_path(event, closed_group))
    end

    it "flags open groups that have reservations to process" do
      group = create(:group, event: event, status: :open)
      create(:reservation, group: group, status: :requested)

      get root_path

      expect(response.body).to include("da elaborare")
    end

    it "shows an empty state when there are no open groups" do
      get root_path

      expect(response.body).to include(I18n.t("groups.index.empty"))
    end

    it "lists reservations to approve from all events in a single table" do
      reservation = create(:reservation, group: create(:group, event: event), status: :requested)
      create(:reservation, group: create(:group, event: create(:event)), status: :confirmed)

      get root_path

      expect(response.body).to include("Prenotazioni da approvare")
      expect(response.body).to include(reservation.full_name)
    end

    it "does not show the pending reservations table when there is nothing to approve" do
      create(:reservation, group: create(:group, event: event), status: :confirmed)

      get root_path

      expect(response.body).not_to include("Prenotazioni da approvare")
    end

    it "flags open groups that still have reservations to notify" do
      group = create(:group, event: event, status: :open, date: Date.current + 30)
      create(:reservation, group: group)
      group.update!(date: Date.current + 1)

      get root_path

      expect(response.body).to include("da avvisare")
    end

    it "does not flag groups whose reservations have all been notified" do
      group = create(:group, event: event, status: :open, date: Date.current + 1)
      create(:reservation, group: group)

      get root_path

      expect(response.body).not_to include("da avvisare")
    end
  end

  describe "#show" do
    it "renders the group" do
      group = create(:group, event: event)

      get event_group_path(event, group)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.title)
    end

    it "lists reservations with the most recent at the bottom" do
      group = create(:group, event: event)
      older = create(:reservation, group: group, full_name: "Zoe")
      newer = create(:reservation, group: group, full_name: "Amy")

      get event_group_path(event, group)

      expect(response.body.index(older.full_name)).to be < response.body.index(newer.full_name)
    end

    it "shows the notified column with a checkbox once inside the notification window" do
      group = create(:group, event: event, date: Date.current + 1)
      create(:reservation, group: group)

      get event_group_path(event, group)

      expect(response.body).to include(I18n.t("groups.show.notified"))
      expect(response.body).to include("reservation[notified]")
    end

    it "hides the to-notify column before the notification window opens" do
      group = create(:group, event: event, date: Date.current + 30)
      create(:reservation, group: group)

      get event_group_path(event, group)

      expect(response.body).not_to include("reservation[notified]")
    end

    it "renders the copy-message icon button when the event has a message template" do
      event = create(:event, message_template: "Ciao <%= nome_completo %>")
      group = create(:group, event: event)
      reservation = create(:reservation, group: group)

      get event_group_path(event, group)

      expect(response.body).to include("Ciao #{reservation.full_name}")
      expect(response.body).to include("aria-label=\"#{I18n.t('groups.show.copy_message')}\"")
      expect(response.body).to include("data-controller=\"clipboard\"")
    end
  end

  describe "#new" do
    it "renders the form" do
      get new_event_group_path(event)

      expect(response).to have_http_status(:ok)
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

    it "stores the per-group capacity overrides" do
      attributes = { date: Date.current, time: "10:00", status: "open", max_group_size: 3, max_overbooking: 1 }

      post event_groups_path(event), params: { group: attributes }

      group = event.groups.order(:id).last
      expect(group.max_group_size).to eq(3)
      expect(group.max_overbooking).to eq(1)
    end
  end

  describe "#update" do
    it "updates the group and stays on the group page" do
      group = create(:group, event: event)

      patch event_group_path(event, group), params: { group: { status: "closed" } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(group.reload).to be_closed
    end

    it "sets the net price inline and redirects so Turbo can morph" do
      group = create(:group, event: event)

      patch event_group_path(event, group), params: { inline: "1", group: { net_price: "42.50" } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(group.reload.net_price).to eq(42.50)
    end

    it "stores the per-group notify_days_before override" do
      group = create(:group, event: event)

      patch event_group_path(event, group), params: { group: { notify_days_before: 7 } }

      expect(group.reload.notify_days_before).to eq(7)
    end

    it "reverts and redirects with an alert when an inline edit is invalid" do
      group = create(:group, event: event, net_price: 10)

      patch event_group_path(event, group), params: { inline: "1", group: { net_price: "-5" } }

      expect(response).to redirect_to(event_group_path(event, group))
      expect(flash[:alert]).to be_present
      expect(group.reload.net_price).to eq(10)
    end

    it "re-renders the form with invalid attributes" do
      group = create(:group, event: event)

      patch event_group_path(event, group), params: { group: { date: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(group.reload.date).to be_present
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

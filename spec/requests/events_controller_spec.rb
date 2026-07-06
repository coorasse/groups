require "rails_helper"

RSpec.describe EventsController, type: :request do
  before { sign_in }

  describe "#index" do
    it "lists the events" do
      event = create(:event)

      get events_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.title)
    end

    it "opts out of the Turbo cache so the to-process counts stay fresh" do
      get events_path

      expect(response.body).to include('name="turbo-cache-control" content="no-cache"')
    end
  end

  describe "#show" do
    it "renders the event with its groups" do
      event = create(:event)
      create(:group, event: event)

      get event_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.title)
    end

    it "highlights reservations to process" do
      event = create(:event)
      create(:reservation, group: create(:group, event: event), status: :requested)

      get event_path(event)

      expect(response.body).to include("da elaborare")
    end

    it "opts out of the Turbo cache so the to-process banner stays fresh" do
      get event_path(create(:event))

      expect(response.body).to include('name="turbo-cache-control" content="no-cache"')
    end
  end

  describe "#index" do
    it "flags events that have reservations to process" do
      event = create(:event)
      create(:reservation, group: create(:group, event: event), status: :requested)

      get events_path

      expect(response.body).to include("da elaborare")
    end

    it "lists reservations to approve from all events in a single table" do
      event = create(:event)
      reservation = create(:reservation, group: create(:group, event: event), status: :requested)
      create(:reservation, group: create(:group, event: create(:event)), status: :confirmed)

      get events_path

      expect(response.body).to include("Prenotazioni da approvare")
      expect(response.body).to include(reservation.full_name)
    end

    it "does not show the pending reservations table when there is nothing to approve" do
      create(:reservation, group: create(:group, event: create(:event)), status: :confirmed)

      get events_path

      expect(response.body).not_to include("Prenotazioni da approvare")
    end
  end

  describe "#new" do
    it "renders the form" do
      get new_event_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    it "creates an event with valid attributes" do
      attributes = attributes_for(:event)

      expect { post events_path, params: { event: attributes } }.to change(Event, :count).by(1)

      expect(response).to redirect_to(Event.last)
    end

    it "does not create an event with invalid attributes" do
      attributes = attributes_for(:event, title: "")

      expect { post events_path, params: { event: attributes } }.not_to change(Event, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "attaches an image and stores the description and message template" do
      image = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/event.png"), "image/png")
      attributes = attributes_for(:event).merge(description: "Una gita fantastica",
        message_template: "Salve <%= nome_completo %>", image: image)

      post events_path, params: { event: attributes }

      expect(Event.last.description).to eq("Una gita fantastica")
      expect(Event.last.message_template).to eq("Salve <%= nome_completo %>")
      expect(Event.last.image).to be_attached
    end
  end

  describe "#update" do
    it "updates the event" do
      event = create(:event)

      patch event_path(event), params: { event: { title: "Aggiornato" } }

      expect(response).to redirect_to(event)
      expect(event.reload.title).to eq("Aggiornato")
    end

    it "re-renders the form with invalid attributes" do
      event = create(:event)

      patch event_path(event), params: { event: { title: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(event.reload.title).not_to eq("")
    end
  end

  describe "#destroy" do
    it "deletes the event" do
      event = create(:event)

      expect { delete event_path(event) }.to change(Event, :count).by(-1)

      expect(response).to redirect_to(events_path)
    end
  end
end

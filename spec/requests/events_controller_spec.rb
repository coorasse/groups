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
  end

  describe "#show" do
    it "renders the event with its groups" do
      event = create(:event)
      create(:group, event: event)

      get event_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.title)
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

    it "attaches an image and stores the description" do
      image = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/event.png"), "image/png")
      attributes = attributes_for(:event).merge(description: "Una gita fantastica", image: image)

      post events_path, params: { event: attributes }

      expect(Event.last.description).to eq("Una gita fantastica")
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
  end

  describe "#destroy" do
    it "deletes the event" do
      event = create(:event)

      expect { delete event_path(event) }.to change(Event, :count).by(-1)

      expect(response).to redirect_to(events_path)
    end
  end
end

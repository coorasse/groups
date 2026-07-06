require "rails_helper"

RSpec.describe Event do
  it "has a valid factory" do
    expect(build(:event)).to be_valid
  end

  it "requires a title" do
    expect(build(:event, title: nil)).not_to be_valid
  end

  it "requires a positive max_group_size" do
    expect(build(:event, max_group_size: 0)).not_to be_valid
  end

  it "rejects negative prices" do
    expect(build(:event, adult_price: -1)).not_to be_valid
  end

  it "rejects a ticket price above the public price" do
    event = build(:event, adult_price: 20, adult_ticket_price: 25)

    expect(event).not_to be_valid
    expect(event.errors[:adult_ticket_price]).to include(
      I18n.t("activerecord.errors.models.event.attributes.adult_ticket_price.above_public_price")
    )
  end

  it "allows a ticket price equal to the public price" do
    expect(build(:event, kid_price: 10, kid_ticket_price: 10)).to be_valid
  end

  it "requires the guided tour prices" do
    expect(build(:event, adult_guided_tour_price: nil)).not_to be_valid
  end

  describe "image" do
    def attach_image(event, content_type: "image/png", filename: "event.png")
      event.image.attach(io: File.open(Rails.root.join("spec/fixtures/files/event.png")),
        filename: filename, content_type: content_type)
      event
    end

    it "accepts a valid image" do
      expect(attach_image(build(:event))).to be_valid
    end

    it "rejects a non-image file" do
      event = build(:event)
      event.image.attach(io: StringIO.new("plain text"), filename: "event.txt", content_type: "text/plain")

      expect(event).not_to be_valid
    end
  end

  describe "#message_for" do
    let(:event) do
      build(:event, message_template: "Ciao <%= nome_completo %> per <%= titolo_evento %><% if numero_ragazzi > 0 %> con <%= numero_ragazzi %> ragazzi<% end %>. Importo <%= importo_totale %>")
    end

    let(:vars) do
      { nome_completo: "Mario", titolo_evento: "Gita", data_ora_gruppo: "oggi",
        numero_adulti: 2, numero_ragazzi: 1, importo_totale: "45,00 €" }
    end

    it "interpolates the variables with the provided values" do
      result = event.message_for(**vars)

      expect(result).to include("Ciao Mario per Gita")
      expect(result).to include("Importo 45,00 €")
    end

    it "renders the conditional part when there are kids" do
      expect(event.message_for(**vars)).to include("con 1 ragazzi")
    end

    it "hides the conditional part when there are no kids" do
      expect(event.message_for(**vars.merge(numero_ragazzi: 0))).not_to include("ragazzi")
    end

    it "returns an empty string when no template is set" do
      expect(build(:event, message_template: nil).message_for(**vars)).to eq("")
    end

    it "falls back to the raw template when the ERB is broken" do
      event = build(:event, message_template: "Ciao <%= nome_completo %><% if %>")

      expect(event.message_for(**vars)).to eq("Ciao <%= nome_completo %><% if %>")
    end
  end

  it "counts requested reservations across its groups" do
    event = create(:event)
    group = create(:group, event: event)
    create(:reservation, group: group, status: :requested)
    create(:reservation, group: group, status: :confirmed)

    expect(event.reservations.requested.count).to eq(1)
  end

  it "destroys its groups when destroyed" do
    event = create(:event)
    create(:group, event: event)

    expect { event.destroy }.to change(Group, :count).by(-1)
  end
end

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#flash_css_class" do
    it "maps known flash types to Bulma classes" do
      expect(helper.flash_css_class(:notice)).to eq("is-success")
      expect(helper.flash_css_class(:alert)).to eq("is-danger")
    end

    it "falls back to is-info for unknown types" do
      expect(helper.flash_css_class(:warning)).to eq("is-info")
    end
  end

  describe "#gravatar_url" do
    it "builds a gravatar URL from the MD5 of the normalized email" do
      url = helper.gravatar_url(" Admin@Example.com ")

      expect(url).to eq("https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest('admin@example.com')}?s=64&d=robohash")
    end

    it "accepts a custom size" do
      expect(helper.gravatar_url("admin@example.com", size: 128)).to include("s=128")
    end
  end

  describe "#price_difference_tag" do
    it "renders a neutral dash for a zero difference" do
      expect(helper.price_difference_tag(0)).to include("—")
    end

    it "renders a positive difference in red with a plus sign" do
      tag = helper.price_difference_tag(5)

      expect(tag).to include("has-text-danger")
      expect(tag).to include("+")
    end

    it "renders a negative difference in green with a minus sign" do
      tag = helper.price_difference_tag(-5)

      expect(tag).to include("has-text-success")
      expect(tag).to include("−")
    end
  end
end

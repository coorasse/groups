require "rails_helper"

RSpec.describe EventsHelper, type: :helper do
  describe "#highlight_erb" do
    it "wraps output tags in an erb-output span" do
      result = helper.highlight_erb("Ciao <%= nome_completo %>")

      expect(result).to include('<span class="erb-output">&lt;%= nome_completo %&gt;</span>')
    end

    it "wraps control tags in an erb-control span" do
      result = helper.highlight_erb("<% if numero_ragazzi > 0 %>x<% end %>")

      expect(result).to include('<span class="erb-control">&lt;% if numero_ragazzi &gt; 0 %&gt;</span>')
      expect(result).to include('<span class="erb-control">&lt;% end %&gt;</span>')
    end

    it "escapes the surrounding plain text without wrapping it" do
      result = helper.highlight_erb("a & b <%= x %>")

      expect(result).to include("a &amp; b ")
      expect(result).to be_html_safe
    end
  end
end

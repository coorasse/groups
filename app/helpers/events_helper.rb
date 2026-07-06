module EventsHelper
  ERB_TAG = /(&lt;%=?.*?%&gt;)/m

  # Wraps ERB tags (`<%= ... %>` and `<% ... %>`) of an already HTML-escaped
  # template in spans so they can be highlighted via CSS.
  def highlight_erb(source)
    segments = ERB::Util.html_escape(source).split(ERB_TAG)
    safe_join(segments.map do |segment|
      if segment.match?(ERB_TAG)
        css_class = segment.start_with?("&lt;%=") ? "erb-output" : "erb-control"
        tag.span(segment.html_safe, class: css_class)
      else
        segment.html_safe
      end
    end)
  end
end

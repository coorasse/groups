module ApplicationHelper
  FLASH_CSS_CLASSES = {
    "notice" => "is-success",
    "alert" => "is-danger"
  }.freeze

  def flash_css_class(type)
    FLASH_CSS_CLASSES.fetch(type.to_s, "is-info")
  end

  # Inline SVG icons (feather-style) used for action buttons.
  ICON_PATHS = {
    edit: "M12 20h9 M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4 12.5-12.5z",
    destroy: "M3 6h18 M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2 M10 11v6 M14 11v6",
    copy: "M9 9h10a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H9a2 2 0 0 1-2-2V11a2 2 0 0 1 2-2z M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1",
    notes: "M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
  }.freeze

  def action_icon(name)
    svg = <<~SVG.html_safe
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18"
           fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
           stroke-linejoin="round" aria-hidden="true"><path d="#{ICON_PATHS.fetch(name)}"/></svg>
    SVG
    tag.span(svg, class: "icon is-small")
  end

  # Unified card used across the site. Renders a Bulma box with an optional
  # label (heading). Pass the content as a block or via `body:`.
  def card(title: nil, centered: false, body: nil, &block)
    content = body || capture(&block)
    tag.div(class: class_names("box", "has-text-centered" => centered)) do
      safe_join([ (tag.p(title, class: "heading") if title), content ].compact)
    end
  end

  # A card showing a single value under its label, wrapped in a Bulma column.
  def stat_card(label, column_class: "is-one-quarter", &block)
    value = tag.div(capture(&block), class: "is-size-5 has-text-weight-bold")
    tag.div(class: "column #{column_class}") { card(title: label, centered: true, body: value) }
  end

  # Column header that shrinks on mobile: shows the full label on tablet and up,
  # and a shorter one on mobile to keep table columns narrow.
  def responsive_label(full, short)
    safe_join([
      tag.span(full, class: "is-hidden-mobile"),
      tag.span(short, class: "is-hidden-tablet")
    ])
  end

  def gravatar_url(email_address, size: 64)
    digest = Digest::MD5.hexdigest(email_address.strip.downcase)
    "https://www.gravatar.com/avatar/#{digest}?s=#{size}&d=robohash"
  end

  def price_difference_tag(difference)
    return tag.span("—", class: "has-text-grey") if difference.zero?

    css_class = difference.positive? ? "has-text-danger" : "has-text-success"
    sign = difference.positive? ? "+" : "−"
    tag.span("#{sign}#{number_to_currency(difference.abs)}", class: css_class)
  end
end

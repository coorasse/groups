module ApplicationHelper
  FLASH_CSS_CLASSES = {
    "notice" => "is-success",
    "alert" => "is-danger"
  }.freeze

  def flash_css_class(type)
    FLASH_CSS_CLASSES.fetch(type.to_s, "is-info")
  end

  def stat_card(label, column_class: "is-one-quarter", &block)
    tag.div(class: "column #{column_class}") do
      tag.div(class: "box has-text-centered") do
        safe_join([
          tag.p(label, class: "heading"),
          tag.div(capture(&block), class: "is-size-5 has-text-weight-bold")
        ])
      end
    end
  end

  def price_difference_tag(difference)
    return tag.span("—", class: "has-text-grey") if difference.zero?

    css_class = difference.positive? ? "has-text-danger" : "has-text-success"
    sign = difference.positive? ? "+" : "−"
    tag.span("#{sign}#{number_to_currency(difference.abs)}", class: css_class)
  end
end

module ApplicationHelper
  FLASH_CSS_CLASSES = {
    "notice" => "is-success",
    "alert" => "is-danger"
  }.freeze

  def flash_css_class(type)
    FLASH_CSS_CLASSES.fetch(type.to_s, "is-info")
  end

  def price_difference_tag(difference)
    return tag.span("—", class: "has-text-grey") if difference.zero?

    css_class = difference.positive? ? "has-text-danger" : "has-text-success"
    sign = difference.positive? ? "+" : "−"
    tag.span("#{sign}#{number_to_currency(difference.abs)}", class: css_class)
  end
end

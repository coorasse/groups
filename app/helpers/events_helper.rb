module EventsHelper
  # Renders a money input: the value is formatted to two decimals so stored prices
  # read as "15.00" rather than "15.0", while step 1 keeps the spinner buttons
  # moving one whole unit at a time (prices are handled in whole euros).
  def price_input(form, attribute)
    value = form.object.public_send(attribute)
    form.input attribute,
               label_html: { class: "is-small" },
               input_html: { step: 1, min: 0, value: (format("%.2f", value) if value) }
  end
end

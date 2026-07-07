module ReservationsHelper
  STATUS_TAG_CLASSES = {
    "requested" => "is-warning",
    "approved" => "is-info",
    "confirmed" => "is-success",
    "paid" => "is-primary",
    "cancelled" => "is-danger is-light"
  }.freeze

  def reservation_status_label(status)
    t(status, scope: "reservations.statuses")
  end

  def reservation_status_options
    Reservation.statuses.keys.map { |status| [ reservation_status_label(status), status ] }
  end

  def reservation_status_tag(reservation)
    tag.span(reservation_status_label(reservation.status),
      class: "tag #{STATUS_TAG_CLASSES.fetch(reservation.status)}")
  end

  def to_process_tag(count)
    tag.span(t("reservations.to_process", count: count), class: "tag is-warning")
  end

  def to_notify_tag(count)
    tag.span(t("reservations.to_notify", count: count), class: "tag is-link")
  end

  def reservation_message(reservation)
    event = reservation.group.event
    event.message_for(
      nome_completo: reservation.full_name,
      titolo_evento: event.title,
      data_ora_gruppo: group_full_datetime(reservation.group),
      numero_adulti: reservation.adults_count,
      numero_ragazzi: reservation.kids_count,
      importo_totale: number_to_currency(reservation.price_to_pay),
      confirmation_link: booking_url(reservation.token)
    )
  end

  def reservation_status_count_tag(status, count)
    tag.span(class: "tag #{STATUS_TAG_CLASSES.fetch(status)}") do
      safe_join([ reservation_status_label(status), tag.strong(count) ], ": ")
    end
  end
end

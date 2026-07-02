module ReservationsHelper
  STATUS_TAG_CLASSES = {
    "requested" => "is-warning",
    "approved" => "is-info",
    "confirmed" => "is-success",
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

  def reservation_status_count_tag(status, count)
    tag.span(class: "tag #{STATUS_TAG_CLASSES.fetch(status)}") do
      safe_join([ reservation_status_label(status), tag.strong(count) ], ": ")
    end
  end
end

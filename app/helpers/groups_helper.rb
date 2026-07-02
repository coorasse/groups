module GroupsHelper
  STATUS_TAG_CLASSES = {
    "open" => "is-info",
    "closed" => "is-warning",
    "completed" => "is-success",
    "cancelled" => "is-danger"
  }.freeze

  def group_status_label(status)
    t(status, scope: "groups.statuses")
  end

  def group_status_options
    Group.statuses.keys.map { |status| [ group_status_label(status), status ] }
  end

  def group_status_tag(group)
    tag.span(group_status_label(group.status), class: "tag #{STATUS_TAG_CLASSES.fetch(group.status)}")
  end

  def seats_left_tag(group)
    seats = group.remaining_seats
    css_class = seats.negative? ? "has-text-danger has-text-weight-bold" : "has-text-weight-semibold"
    tag.span(seats, class: css_class)
  end

  def group_label(group)
    [
      (l(group.date, format: :day_short) if group.date),
      (l(group.time, format: :hour_minute) if group.time)
    ].compact.join(" ")
  end
end

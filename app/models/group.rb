class Group < ApplicationRecord
  belongs_to :event
  has_many :reservations, dependent: :destroy

  enum :status, { open: 0, closed: 1, completed: 2, cancelled: 3 }, default: :open

  validates :date, :time, presence: true
  validates :net_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_group_size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :max_overbooking, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_nil: true

  scope :upcoming_candidates, -> { where(date: Date.current..) }

  def starts_at
    return if date.blank? || time.blank?

    Time.zone.local(date.year, date.month, date.day, time.hour, time.min)
  end

  def upcoming?
    starts_at.present? && starts_at.future?
  end

  # Capacity is inherited from the event but can be overridden per group.
  def effective_max_group_size
    max_group_size || event.max_group_size
  end

  def effective_max_overbooking
    max_overbooking || event.max_overbooking
  end

  # How many days before the group the confirmations must be sent out. Inherited
  # from the event but can be overridden per group.
  def effective_notify_days_before
    notify_days_before || event.notify_days_before
  end

  # The confirmation phase opens `effective_notify_days_before` days before the
  # group takes place: from that day on the operator is expected to notify the
  # reservations.
  def within_notify_window?
    date.present? && Date.current >= date - effective_notify_days_before
  end

  def reservations_to_notify
    reservations.active.where(notified: false)
  end

  # A group needs attention while it is in the confirmation phase and still has
  # active reservations that have not been notified yet.
  def needs_notification?
    within_notify_window? && reservations_to_notify.exists?
  end

  # Total number of people the group can hold, overbooking included.
  def total_capacity
    effective_max_group_size + effective_max_overbooking
  end

  # A group is offered on the public form only while it still has plain seats
  # available: as soon as they run out it disappears from the bookable list,
  # even though the overbooking allowance could still absorb a request handled
  # by an operator.
  def bookable?
    open? && upcoming? && remaining_seats.positive?
  end

  # Whether a reservation of `count` people still fits within the plain seats
  # plus the overbooking allowance. Requests within this ceiling are confirmed
  # automatically; anything beyond it needs an operator's decision.
  def fits_within_overbooking?(count)
    people_count + count <= total_capacity
  end

  def adults_count
    reservations.active.sum(:adults_count)
  end

  def kids_count
    reservations.active.sum(:kids_count)
  end

  def people_count
    adults_count + kids_count
  end

  def remaining_seats
    effective_max_group_size - people_count
  end

  def people_count_for(status)
    reservations.where(status: status).sum(Arel.sql("adults_count + kids_count"))
  end

  def computed_price
    reservations.active.sum(&:computed_price)
  end

  def total_price
    reservations.active.sum(:price_to_pay)
  end

  def price_difference
    total_price - computed_price
  end
end

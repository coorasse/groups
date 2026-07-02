class Group < ApplicationRecord
  belongs_to :event
  has_many :reservations, dependent: :destroy

  enum :status, { open: 0, closed: 1, completed: 2, cancelled: 3 }, default: :open

  validates :date, :time, presence: true
  validates :net_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :upcoming_candidates, -> { where(date: Date.current..) }

  def starts_at
    return if date.blank? || time.blank?

    Time.zone.local(date.year, date.month, date.day, time.hour, time.min)
  end

  def upcoming?
    starts_at.present? && starts_at.future?
  end

  def bookable?
    open? && upcoming?
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
    event.max_group_size - people_count
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

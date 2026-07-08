class Reservation < ApplicationRecord
  belongs_to :group

  has_secure_token

  broadcasts_refreshes

  enum :status, { requested: 0, confirmed: 2, paid: 4, cancelled: 3 }, default: :confirmed

  scope :active, -> { where.not(status: :cancelled) }

  before_validation :normalize_full_name
  before_validation :normalize_kids_count
  before_validation :set_price_to_pay
  before_create :mark_notified_within_window

  validates :full_name, presence: true
  validates :adults_count, :kids_count, :guided_tour_only_adults,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :adults_count, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }, on: :public_booking
  validates :kids_count, numericality: { less_than_or_equal_to: 100 }, on: :public_booking
  validates :price_to_pay, numericality: { greater_than_or_equal_to: 0 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :tax_code, format: { with: /\A[A-Za-z0-9]{16}\z/ }, allow_blank: true
  validates :phone, presence: true, on: :public_booking
  validate :must_have_people
  validate :guided_tour_only_within_adults
  validate :data_processing_consent, on: :public_booking

  def people_count
    adults_count.to_i + kids_count.to_i
  end

  def price_difference
    price_to_pay.to_d - computed_price
  end

  # Adults doing the guided tour only (they already have entry) pay the reduced
  # guided-tour price; the remaining adults pay the full price.
  def full_price_adults
    [ adults_count.to_i - guided_tour_only_adults.to_i, 0 ].max
  end

  def computed_price
    return 0 if group.blank?

    event = group.event
    full_price_adults * event.adult_price +
      (adults_count.to_i - full_price_adults) * event.adult_guided_tour_price +
      kids_count.to_i * event.kid_price
  end

  private

  # Capitalizes each word so all-lowercase or all-uppercase names get tidied up.
  def normalize_full_name
    return if full_name.blank?

    self.full_name = full_name.split.map(&:capitalize).join(" ")
  end

  # Kids count is optional on the public form: a blank value means "no kids".
  def normalize_kids_count
    self.kids_count = 0 if kids_count_before_type_cast.blank?
  end

  # The price is computed automatically when it is blank, and it is always
  # recomputed (overwriting any manual value) when the adults or kids count of an
  # existing reservation changes - e.g. when edited inline from the table.
  def set_price_to_pay
    return unless price_to_pay.blank? || (persisted? && (adults_count_changed? || kids_count_changed?))

    self.price_to_pay = computed_price
  end

  # A reservation that comes in when the group is already in its confirmation
  # window has effectively been dealt with on the spot, so it is considered
  # already notified and does not show up in the "to notify" list.
  def mark_notified_within_window
    self.notified = true if group&.within_notify_window?
  end

  def must_have_people
    errors.add(:base, :empty_reservation) if people_count.zero?
  end

  def data_processing_consent
    errors.add(:base, :consent_required) unless data_processing_authorized?
  end

  def guided_tour_only_within_adults
    return if guided_tour_only_adults.blank? || adults_count.blank?

    errors.add(:guided_tour_only_adults, :more_than_adults) if guided_tour_only_adults > adults_count
  end
end

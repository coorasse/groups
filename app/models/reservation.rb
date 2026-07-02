class Reservation < ApplicationRecord
  belongs_to :group

  enum :status, { requested: 0, approved: 1, confirmed: 2, cancelled: 3 }, default: :confirmed

  scope :active, -> { where.not(status: :cancelled) }

  before_validation :set_default_price

  validates :full_name, presence: true
  validates :adults_count, :kids_count, :owned_adult_tickets,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price_to_pay, numericality: { greater_than_or_equal_to: 0 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :tax_code, format: { with: /\A[A-Za-z0-9]{16}\z/ }, allow_blank: true
  validates :phone, presence: true, on: :public_booking
  validate :must_have_people
  validate :owned_tickets_within_adults
  validate :data_processing_consent, on: :public_booking

  def people_count
    adults_count.to_i + kids_count.to_i
  end

  def price_difference
    price_to_pay.to_d - computed_price
  end

  def adult_tickets_to_buy
    [ adults_count.to_i - owned_adult_tickets.to_i, 0 ].max
  end

  def adults_with_ticket
    adults_count.to_i - adult_tickets_to_buy
  end

  def computed_price
    return 0 if group.blank?

    event = group.event
    adult_tickets_to_buy * event.adult_price +
      adults_with_ticket * event.adult_guided_tour_price +
      kids_count.to_i * event.kid_price
  end

  private

  def set_default_price
    self.price_to_pay = computed_price if price_to_pay.blank?
  end

  def must_have_people
    errors.add(:base, :empty_reservation) if people_count.zero?
  end

  def data_processing_consent
    errors.add(:base, :consent_required) unless data_processing_authorized?
  end

  def owned_tickets_within_adults
    return if owned_adult_tickets.blank? || adults_count.blank?

    errors.add(:owned_adult_tickets, :more_than_adults) if owned_adult_tickets > adults_count
  end
end

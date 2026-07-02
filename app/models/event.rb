class Event < ApplicationRecord
  ALLOWED_IMAGE_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze
  MAX_IMAGE_SIZE = 5.megabytes

  has_many :groups, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true
  validates :adult_price, :kid_price, :adult_ticket_price, :kid_ticket_price,
            :adult_guided_tour_price, :kid_guided_tour_price,
            presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_group_size, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :ticket_prices_within_public_prices
  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?

    errors.add(:image, :invalid_type) unless image.content_type.in?(ALLOWED_IMAGE_TYPES)
    errors.add(:image, :too_big, size: MAX_IMAGE_SIZE / 1.megabyte) if image.byte_size > MAX_IMAGE_SIZE
  end

  def ticket_prices_within_public_prices
    errors.add(:adult_ticket_price, :above_public_price) if exceeds?(adult_ticket_price, adult_price)
    errors.add(:kid_ticket_price, :above_public_price) if exceeds?(kid_ticket_price, kid_price)
  end

  def exceeds?(ticket_price, public_price)
    ticket_price.present? && public_price.present? && ticket_price > public_price
  end
end

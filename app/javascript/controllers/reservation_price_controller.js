import { Controller } from "@hotwired/stimulus"

export default class ReservationPriceController extends Controller {
  static targets = ["adultsCount", "kidsCount", "guidedTourOnlyAdults", "priceToPay", "suggestedPrice", "priceBreakdown"]
  static values = {
    adultPrice: Number,
    kidPrice: Number,
    adultGuidedTourPrice: Number,
    adultLabel: { type: String, default: "adults" },
    guidedTourLabel: { type: String, default: "guided tour only" },
    kidLabel: { type: String, default: "kids" },
    currency: { type: String, default: "€" },
    persisted: Boolean
  }

  connect() {
    this.overridden = this.persistedValue
    this.recalculate()
  }

  markOverridden() {
    this.overridden = true
  }

  useComputed() {
    this.overridden = false
    this.recalculate()
  }

  recalculate() {
    const adults = this.intValue(this.adultsCountTarget)
    const kids = this.intValue(this.kidsCountTarget)
    const guidedTourOnly = this.hasGuidedTourOnlyAdultsTarget ? this.intValue(this.guidedTourOnlyAdultsTarget) : 0

    const guidedTourAdults = Math.min(guidedTourOnly, adults)
    const fullPriceAdults = adults - guidedTourAdults

    const price = fullPriceAdults * this.adultPriceValue +
      guidedTourAdults * this.adultGuidedTourPriceValue +
      kids * this.kidPriceValue

    if (this.hasSuggestedPriceTarget) this.suggestedPriceTarget.textContent = this.format(price)
    if (this.hasPriceBreakdownTarget) {
      this.priceBreakdownTarget.textContent = this.breakdown(fullPriceAdults, guidedTourAdults, kids)
    }

    if (!this.overridden && this.hasPriceToPayTarget) {
      this.priceToPayTarget.value = price.toFixed(2)
    }
  }

  breakdown(fullPriceAdults, guidedTourAdults, kids) {
    const parts = [
      [fullPriceAdults, this.adultPriceValue, this.adultLabelValue],
      [kids, this.kidPriceValue, this.kidLabelValue],
      [guidedTourAdults, this.adultGuidedTourPriceValue, this.guidedTourLabelValue]
    ]

    return parts
      .filter(([count]) => count > 0)
      .map(([count, unitPrice, label]) => `${count} ${label} × ${this.format(unitPrice)}`)
      .join(" + ")
  }

  intValue(element) {
    const value = parseInt(element.value, 10)
    return Number.isNaN(value) ? 0 : value
  }

  format(value) {
    return `${value.toFixed(2)} ${this.currencyValue}`
  }
}

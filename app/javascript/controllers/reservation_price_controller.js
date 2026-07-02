import { Controller } from "@hotwired/stimulus"

export default class ReservationPriceController extends Controller {
  static targets = ["adultsCount", "kidsCount", "ownedAdultTickets", "priceToPay", "ticketsToBuy", "suggestedPrice"]
  static values = {
    adultPrice: Number,
    kidPrice: Number,
    adultGuidedTourPrice: Number,
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
    const owned = this.hasOwnedAdultTicketsTarget ? this.intValue(this.ownedAdultTicketsTarget) : 0

    const ticketsToBuy = Math.max(adults - owned, 0)
    const adultsWithTicket = adults - ticketsToBuy

    const price = ticketsToBuy * this.adultPriceValue +
      adultsWithTicket * this.adultGuidedTourPriceValue +
      kids * this.kidPriceValue

    if (this.hasTicketsToBuyTarget) this.ticketsToBuyTarget.textContent = ticketsToBuy
    if (this.hasSuggestedPriceTarget) this.suggestedPriceTarget.textContent = this.format(price)

    if (!this.overridden && this.hasPriceToPayTarget) {
      this.priceToPayTarget.value = price.toFixed(2)
    }
  }

  intValue(element) {
    const value = parseInt(element.value, 10)
    return Number.isNaN(value) ? 0 : value
  }

  format(value) {
    return `${value.toFixed(2)} ${this.currencyValue}`
  }
}

import { Controller } from "@hotwired/stimulus"

// Drives the public booking form: keeps the hidden group_id in sync with the
// selected date, greys out and disables the dates that cannot take the current
// party, and — when the chosen date is full — blocks the normal confirmation
// while offering to send the request to an operator instead.
export default class BookingController extends Controller {
  static targets = ["adultsCount", "kidsCount", "group", "groupId", "slot", "submit", "warning", "request"]

  connect() {
    this.refresh()
  }

  selectGroup(event) {
    this.groupIdTarget.value = event.target.value
    this.refresh()
  }

  refresh() {
    const party = this.intValue(this.adultsCountTarget) + this.intValue(this.kidsCountTarget)

    this.groupTargets.forEach((radio) => {
      const remaining = parseInt(radio.dataset.remaining, 10)
      const full = party > 0 && remaining < party
      radio.disabled = full
      radio.closest(".booking-slot").classList.toggle("is-full", full)
    })

    const selectedId = this.groupIdTarget.value
    const selected = this.groupTargets.find((radio) => radio.value === selectedId)
    this.groupTargets.forEach((radio) => { radio.checked = radio.value === selectedId })

    const fits = selected && party > 0 && parseInt(selected.dataset.remaining, 10) >= party
    const overCapacity = Boolean(party > 0 && selected && !fits)

    this.submitTarget.disabled = !fits
    this.warningTarget.hidden = !overCapacity
    this.requestTarget.hidden = !overCapacity
  }

  intValue(element) {
    const value = parseInt(element.value, 10)
    return Number.isNaN(value) ? 0 : value
  }
}

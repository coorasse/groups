import { Controller } from "@hotwired/stimulus"

export default class SearchController extends Controller {
  static targets = ["form", "dropdown"]
  static values = { delay: { type: Number, default: 250 } }

  open() {
    this.dropdownTarget.classList.add("is-active")
  }

  submit() {
    this.open()
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.formTarget.requestSubmit(), this.delayValue)
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.remove("is-active")
    }
  }
}

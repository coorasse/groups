import { Controller } from "@hotwired/stimulus"

export default class SearchController extends Controller {
  static targets = ["form"]
  static values = { delay: { type: Number, default: 250 } }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.formTarget.requestSubmit(), this.delayValue)
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.element.querySelector(".search-panel")?.remove()
    }
  }
}

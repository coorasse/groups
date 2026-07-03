import { Controller } from "@hotwired/stimulus"

export default class ClipboardController extends Controller {
  static values = { text: String, copiedLabel: String }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => this.showFeedback())
  }

  showFeedback() {
    if (!this.copiedLabelValue) return

    const original = this.element.textContent
    this.element.textContent = this.copiedLabelValue
    this.element.disabled = true
    setTimeout(() => {
      this.element.textContent = original
      this.element.disabled = false
    }, 1500)
  }
}

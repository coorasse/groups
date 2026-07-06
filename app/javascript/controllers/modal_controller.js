import { Controller } from "@hotwired/stimulus"

export default class ModalController extends Controller {
  connect() {
    this.boundKeydown = this.keydown.bind(this)
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
  }

  keydown(event) {
    if (event.key === "Escape") this.close()
  }

  close() {
    this.element.remove()
  }
}

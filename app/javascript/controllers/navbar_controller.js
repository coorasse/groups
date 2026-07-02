import { Controller } from "@hotwired/stimulus"

export default class NavbarController extends Controller {
  static targets = ["burger", "menu"]

  toggle() {
    this.burgerTarget.classList.toggle("is-active")
    this.menuTarget.classList.toggle("is-active")
  }
}

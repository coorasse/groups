import { Controller } from "@hotwired/stimulus"

export default class AutosubmitController extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}

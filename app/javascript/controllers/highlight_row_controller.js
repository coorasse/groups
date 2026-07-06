import { Controller } from "@hotwired/stimulus"

export default class HighlightRowController extends Controller {
  connect() {
    const id = window.location.hash.slice(1)
    if (!id) return

    const row = this.element.querySelector(`#${CSS.escape(id)}`)
    if (!row) return

    row.scrollIntoView({ block: "center" })
    row.classList.remove("is-highlighted-row")
    void row.offsetWidth // force reflow so the animation replays on repeat visits
    row.classList.add("is-highlighted-row")
  }
}

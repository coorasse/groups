import { Controller } from "@hotwired/stimulus"

export default class SearchController extends Controller {
  static targets = ["form", "dropdown", "input"]
  static values = { delay: { type: Number, default: 250 } }

  open() {
    this.dropdownTarget.classList.add("is-active")
  }

  focus(event) {
    if (event.key !== "f" || !(event.metaKey || event.ctrlKey)) return

    event.preventDefault()
    this.open()
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  submit() {
    this.open()
    this.activeIndex = -1
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.formTarget.requestSubmit(), this.delayValue)
  }

  navigate(event) {
    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.highlight(this.activeIndex + 1)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.highlight(this.activeIndex - 1)
    } else if (event.key === "Enter") {
      const active = this.results[this.activeIndex]
      if (active) {
        event.preventDefault()
        active.click()
      }
    } else if (event.key === "Escape") {
      this.dropdownTarget.classList.remove("is-active")
    }
  }

  highlight(index) {
    const results = this.results
    if (results.length === 0) return

    this.activeIndex = (index + results.length) % results.length
    results.forEach((result, i) => {
      result.classList.toggle("is-highlighted", i === this.activeIndex)
    })
    results[this.activeIndex].scrollIntoView({ block: "nearest" })
  }

  get results() {
    return Array.from(this.dropdownTarget.querySelectorAll(".search-result"))
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.remove("is-active")
    }
  }
}

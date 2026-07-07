import { Controller } from "@hotwired/stimulus"

// Highlights the ERB tags of the editable textarea by mirroring its text into a
// `<pre>` layer rendered underneath. The textarea keeps the real (plain text)
// value, so nothing about form submission changes; the overlay is purely visual.
// Mirrors the server-side `highlight_erb` helper.
export default class ErbHighlightController extends Controller {
  static targets = ["input", "output"]

  static ERB_TAG = /(&lt;%=?[\s\S]*?%&gt;)/g

  connect() {
    this.render()
  }

  render() {
    this.outputTarget.innerHTML = this.highlight(this.inputTarget.value)
    this.sync()
  }

  sync() {
    this.outputTarget.scrollTop = this.inputTarget.scrollTop
    this.outputTarget.scrollLeft = this.inputTarget.scrollLeft
  }

  highlight(source) {
    const highlighted = this.escape(source).replace(ErbHighlightController.ERB_TAG, (tag) => {
      const cssClass = tag.startsWith("&lt;%=") ? "erb-output" : "erb-control"
      return `<span class="${cssClass}">${tag}</span>`
    })

    // Trailing newline keeps the last line's height in sync with the textarea.
    return `${highlighted}\n`
  }

  escape(source) {
    return source.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }
}

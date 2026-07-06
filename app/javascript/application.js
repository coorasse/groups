// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"
import "controllers"

// Replace Turbo's native confirmation dialog with a Bulma-styled modal.
// The message comes from `data-turbo-confirm`; button labels can be overridden
// per element with `data-turbo-confirm-accept` / `data-turbo-confirm-cancel`.
Turbo.setConfirmMethod((message, element) => {
  return new Promise((resolve) => {
    const accept = element.dataset.turboConfirmAccept || "Conferma"
    const cancel = element.dataset.turboConfirmCancel || "Annulla"

    const modal = document.createElement("div")
    modal.className = "modal is-active"
    modal.innerHTML = `
      <div class="modal-background"></div>
      <div class="modal-card confirm-modal-card" role="alertdialog" aria-modal="true">
        <section class="modal-card-body">
          <p class="is-size-5">${message}</p>
        </section>
        <footer class="modal-card-foot is-justify-content-flex-end">
          <button type="button" class="button" data-confirm-cancel>${cancel}</button>
          <button type="button" class="button is-primary" data-confirm-accept>${accept}</button>
        </footer>
      </div>`

    const finish = (confirmed) => {
      document.removeEventListener("keydown", onKeydown)
      modal.remove()
      resolve(confirmed)
    }

    const onKeydown = (event) => {
      if (event.key === "Escape") finish(false)
    }

    modal.querySelector(".modal-background").addEventListener("click", () => finish(false))
    modal.querySelector("[data-confirm-cancel]").addEventListener("click", () => finish(false))
    modal.querySelector("[data-confirm-accept]").addEventListener("click", () => finish(true))
    document.addEventListener("keydown", onKeydown)

    document.body.appendChild(modal)
    modal.querySelector("[data-confirm-accept]").focus()
  })
})

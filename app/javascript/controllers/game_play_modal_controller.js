import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { reloadOnClose: Boolean }

  connect() {
    if (this.reloadOnCloseValue) this.element.addEventListener("close", this.reload)
    if (!this.element.open) this.element.showModal()
  }

  disconnect() {
    this.element.removeEventListener("close", this.reload)
  }

  close(event) {
    if (event.currentTarget.tagName === "A") event.preventDefault()
    this.element.close()
  }

  reload = () => {
    window.location.reload()
  }
}

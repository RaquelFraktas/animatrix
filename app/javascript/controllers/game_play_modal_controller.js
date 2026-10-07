import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!this.element.open) this.element.showModal()
  }

  close(event) {
    if (event.currentTarget.tagName === "A") event.preventDefault()
    this.element.close()
  }
}
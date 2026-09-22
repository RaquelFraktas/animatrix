import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "output", "input"]

  connect() {
    this.outputTarget.value = ""
  }

  async capture() {
    const value = this.inputTarget.value.trim()
    if (!value) {
      this.outputTarget.value = "Please enter a QR value first."
      return
    }

    this.formTarget.requestSubmit()
  }
}

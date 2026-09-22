import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output", "input"]

  connect() {
    this.outputTarget.value = ""
  }

  async capture() {
    const value = this.inputTarget.value.trim()
    if (!value) {
      this.outputTarget.value = "Please enter a QR value first."
      return
    }

    const response = await fetch("/scan", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ qr_code: value })
    })

    const data = await response.json()

    if (!response.ok) {
      this.outputTarget.value = data.error || "Could not initialize player."
      return
    }

    this.outputTarget.value = `Initialized ${data.name} (${data.status})`
  }
}

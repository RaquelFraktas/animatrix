import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    scoreboardUrl: String,
    redirectDelay: Number
  }

  connect() {
    document.body.classList.add("scan-killed-shake")
    this.redirectTimeout = window.setTimeout(() => {
      window.location.assign(this.scoreboardUrlValue)
    }, this.redirectDelayValue)
  }

  disconnect() {
    document.body.classList.remove("scan-killed-shake")
    window.clearTimeout(this.redirectTimeout)
  }
}
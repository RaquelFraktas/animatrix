import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    count: { type: Number, default: 1 },
    redirectUrl: String,
    redirectDelay: Number
  }

  connect() {
    const body = document.body
    body.classList.remove("page-shake")
    void body.offsetWidth
    body.style.setProperty("--shake-count", this.countValue)
    body.classList.add("page-shake")
    body.addEventListener("animationend", this.stop, { once: true })

    if (this.hasRedirectUrlValue) {
      this.redirectTimeout = window.setTimeout(() => {
        window.location.assign(this.redirectUrlValue)
      }, this.redirectDelayValue)
    }
  }

  disconnect() {
    this.stop()
    window.clearTimeout(this.redirectTimeout)
  }

  stop = () => {
    document.body.classList.remove("page-shake")
    document.body.style.removeProperty("--shake-count")
  }
}

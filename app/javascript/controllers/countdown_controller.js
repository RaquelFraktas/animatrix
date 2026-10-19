import { Controller } from "@hotwired/stimulus"

// Counts down to endsAt, then shows the finished message.
export default class extends Controller {
  static values = { endsAt: String, suffix: String, finished: String }

  connect() {
    this.endsAt = new Date(this.endsAtValue)
    this.tick()
    this.timer = window.setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    window.clearInterval(this.timer)
  }

  tick() {
    const seconds = Math.max(Math.floor((this.endsAt - Date.now()) / 1000), 0)

    if (seconds === 0) {
      this.element.textContent = this.finishedValue
      window.clearInterval(this.timer)
      return
    }

    this.element.textContent = `${this.format(seconds)} ${this.suffixValue}`
  }

  format(seconds) {
    const pad = (n) => String(n).padStart(2, "0")
    const days = Math.floor(seconds / 86400)
    const time = [
      Math.floor(seconds / 3600) % 24,
      Math.floor(seconds / 60) % 60,
      seconds % 60
    ].map(pad).join(":")

    return days > 0 ? `${days}D ${time}` : time
  }
}

import { Controller } from "@hotwired/stimulus"

const COUNT_ANIMATION_DURATION = 650

export default class extends Controller {
  connect() {
    this.previousScores = this.readScores()
    this.animationFrames = new Map()
    this.observer = new MutationObserver(() => this.updateScores())
    this.observer.observe(this.element, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
    this.animationFrames?.forEach((frame) => window.cancelAnimationFrame(frame))
  }

  readScores() {
    return new Map(
      Array.from(this.element.querySelectorAll("[data-scoreboard-user-id]"), (row) => {
        const count = row.querySelector("[data-scoreboard-kills]")

        return [row.dataset.scoreboardUserId, {
          kills: Number(count.dataset.scoreboardKills),
          status: row.dataset.scoreboardStatus
        }]
      })
    )
  }

  updateScores() {
    const currentScores = this.readScores()

    currentScores.forEach((score, userId) => {
      const previousScore = this.previousScores.get(userId)
      const row = this.element.querySelector(`[data-scoreboard-user-id="${userId}"]`)

      if (previousScore?.status === "alive" && score.status === "killed") {
        row.classList.add("is-knocked-out")
      }

      if (previousScore && score.kills > previousScore.kills) {
        this.animateCount(userId, row, previousScore.kills, score.kills)
      }
    })

    this.previousScores = currentScores
  }

  animateCount(userId, row, from, to) {
    const countElement = row.querySelector("[data-scoreboard-kills]")
    const labelElement = row.querySelector("[data-scoreboard-kill-label]")
    const oldFrame = this.animationFrames.get(userId)

    if (oldFrame) window.cancelAnimationFrame(oldFrame)

    let startTime
    const animate = (time) => {
      startTime ??= time
      const progress = Math.min((time - startTime) / COUNT_ANIMATION_DURATION, 1)
      const value = Math.round(from + (to - from) * progress)

      countElement.textContent = value
      labelElement.textContent = value === 1 ? "kill" : "kills"
      row.classList.add("score-count-updated")

      if (progress < 1) {
        this.animationFrames.set(userId, window.requestAnimationFrame(animate))
      } else {
        this.animationFrames.delete(userId)
        window.setTimeout(() => row.classList.remove("score-count-updated"), 450)
      }
    }

    this.animationFrames.set(userId, window.requestAnimationFrame(animate))
  }
}
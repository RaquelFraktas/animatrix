import { Controller } from "@hotwired/stimulus"

const COUNT_ANIMATION_DURATION = 650

export default class extends Controller {
  connect() {
    this.previousScores = this.readScores()
    this.countFrames = new Map()
    this.barFrames = new Map()
    this.positionFrames = new Map()
    this.observer = new MutationObserver(() => this.updateScores())
    this.observer.observe(this.element, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
    ;[this.countFrames, this.barFrames, this.positionFrames].forEach((frames) => {
      frames?.forEach((frame) => window.cancelAnimationFrame(frame))
    })
  }

  readScores() {
    return new Map(
      Array.from(this.element.querySelectorAll("[data-scoreboard-user-id]"), (row) => {
        const count = row.querySelector("[data-scoreboard-kills]")
        const bar = row.querySelector(".kill-chart")

        return [row.dataset.scoreboardUserId, {
          kills: Number(count.dataset.scoreboardKills),
          status: row.dataset.scoreboardStatus,
          barWidth: Number(bar.dataset.scoreboardBarWidth),
          top: row.getBoundingClientRect().top
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

      if (previousScore && score.barWidth !== previousScore.barWidth) {
        this.animateBar(userId, row, previousScore.barWidth, score.barWidth)
      }

      if (previousScore && Math.abs(score.top - previousScore.top) > 1) {
        this.animatePosition(userId, row, previousScore.top - score.top)
      }
    })

    this.previousScores = currentScores
  }

  animateCount(userId, row, from, to) {
    const countElement = row.querySelector("[data-scoreboard-kills]")
    const labelElement = row.querySelector("[data-scoreboard-kill-label]")
    const oldFrame = this.countFrames.get(userId)

    if (oldFrame) window.cancelAnimationFrame(oldFrame)

    let startTime
    const animate = (time) => {
      startTime ??= time
      const progress = Math.min((time - startTime) / COUNT_ANIMATION_DURATION, 1)
      const value = Math.round(from + (to - from) * progress)

      countElement.textContent = value
      if (labelElement) labelElement.textContent = value === 1 ? "kill" : "kills"
      row.classList.add("score-count-updated")

      if (progress < 1) {
        this.countFrames.set(userId, window.requestAnimationFrame(animate))
      } else {
        this.countFrames.delete(userId)
        window.setTimeout(() => row.classList.remove("score-count-updated"), 450)
      }
    }

    this.countFrames.set(userId, window.requestAnimationFrame(animate))
  }

  animateBar(userId, row, from, to) {
    const bar = row.querySelector(".kill-chart")
    const oldFrame = this.barFrames.get(userId)

    if (oldFrame) window.cancelAnimationFrame(oldFrame)

    bar.style.transition = "none"
    bar.style.width = `${from}%`
    bar.offsetWidth

    this.barFrames.set(userId, window.requestAnimationFrame(() => {
      bar.style.transition = ""
      bar.style.width = `${to}%`
      this.barFrames.delete(userId)
    }))
  }

  animatePosition(userId, row, offset) {
    const oldFrame = this.positionFrames.get(userId)

    if (oldFrame) window.cancelAnimationFrame(oldFrame)

    row.style.transition = "none"
    row.style.transform = `translateY(${offset}px)`
    row.offsetHeight

    this.positionFrames.set(userId, window.requestAnimationFrame(() => {
      row.style.transition = ""
      row.style.transform = ""
      this.positionFrames.delete(userId)
    }))
  }
}
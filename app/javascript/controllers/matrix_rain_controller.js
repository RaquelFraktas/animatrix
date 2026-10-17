import { Controller } from "@hotwired/stimulus"

const FONT_SIZE = 20
const CHARACTERS =
  "ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺ" +
  "ｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉ" +
  "ﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓ" +
  "ﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ" +
  "0123456789" +
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
  "*+-<>:|¦"

function random(min, max) {
  return Math.random() * (max - min) + min
}

function randomCharacter() {
  return CHARACTERS[Math.floor(Math.random() * CHARACTERS.length)]
}

// Connect to a <canvas> to draw falling matrix-style characters behind the page.
export default class extends Controller {
  connect() {
    this.ctx = this.element.getContext("2d")
    this.streams = []

    window.addEventListener("resize", this.resize)
    this.resize()
    this.draw()
  }

  disconnect() {
    window.removeEventListener("resize", this.resize)
    cancelAnimationFrame(this.frame)
  }

  resize = () => {
    const dpr = window.devicePixelRatio || 1

    this.element.width = window.innerWidth * dpr
    this.element.height = window.innerHeight * dpr
    this.element.style.width = `${window.innerWidth}px`
    this.element.style.height = `${window.innerHeight}px`
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0)

    this.createStreams()
  }

  createStreams() {
    this.streams = []
    const columnCount = Math.ceil(window.innerWidth / FONT_SIZE)

    for (let column = 0; column < columnCount; column++) {
      // Use about 90% of available columns
      if (Math.random() > 0.1) {
        this.streams.push(this.createStream(column))
      }
    }
  }

  createStream(column) {
    const length = Math.floor(random(6, 18))

    return {
      column,
      // Start above the screen
      y: random(-window.innerHeight, 0),
      length,
      chars: Array.from({ length }, randomCharacter),
      speed: random(1.5, 3.5),
      // How often characters change
      changeRate: random(0.01, 0.05),
      opacity: random(0.35, 0.85)
    }
  }

  resetStream(stream) {
    stream.y = random(-stream.length * FONT_SIZE * 4, -FONT_SIZE)
    stream.length = Math.floor(random(10, 35))
    stream.speed = random(1.5, 3.5)
    stream.changeRate = random(0.01, 0.05)
    stream.opacity = random(0.35, 0.85)
    stream.chars = Array.from({ length: stream.length }, randomCharacter)
  }

  drawStream(stream) {
    const x = stream.column * FONT_SIZE

    for (let i = 0; i < stream.length; i++) {
      const y = stream.y - i * FONT_SIZE

      // Skip characters outside viewport
      if (y < -FONT_SIZE || y > window.innerHeight + FONT_SIZE) continue

      if (Math.random() < stream.changeRate) {
        stream.chars[i] = randomCharacter()
      }

      if (i === 0) {
        // Leading character
        this.ctx.fillStyle = "#ffffff"
      } else {
        // Fade characters as they trail behind
        const fade = Math.pow(1 - i / stream.length, 1.5)
        this.ctx.fillStyle = `rgba(0, 255, 65, ${fade * stream.opacity})`
      }

      this.ctx.fillText(stream.chars[i], x, y)
    }
  }

  draw = () => {
    // Clear previous frames quickly to keep the characters crisp.
    this.ctx.fillStyle = "rgba(0, 0, 0, 0.3)"
    this.ctx.fillRect(0, 0, window.innerWidth, window.innerHeight)
    this.ctx.font = `${FONT_SIZE}px monospace`
    this.ctx.textBaseline = "top"

    for (const stream of this.streams) {
      this.drawStream(stream)
      stream.y += stream.speed

      // Restart after leaving screen
      if (stream.y - stream.length * FONT_SIZE > window.innerHeight) {
        this.resetStream(stream)
      }
    }

    this.frame = requestAnimationFrame(this.draw)
  }
}

const canvas = document.getElementById("matrix-rain");

if (canvas) {
  const ctx = canvas.getContext("2d");
  const fontSize = 20;
  const characters =
    "ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺ" +
    "ｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉ" +
    "ﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓ" +
    "ﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ" +
    "0123456789" +
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
    "*+-<>:|¦";

  // =========================
  // STATE
  // =========================

  let streams = [];
  let columnCount = 0;

  // =========================
  // HELPERS
  // =========================

  function random(min, max) {
    return Math.random() * (max - min) + min;
  }

  function randomCharacter() {
    return characters[
      Math.floor(Math.random() * characters.length)
    ];
  }

  // =========================
  // CREATE STREAM
  // =========================

  function createStream(column) {
    const length = Math.floor(random(6, 18));

    return {
      column,

      // Start above the screen
      y: random(-window.innerHeight, 0),

      // Number of characters
      length,

      // Characters in this stream
      chars: Array.from(
        { length },
        randomCharacter
      ),

      // Falling speed
      speed: random(1.5, 3.5),

      // How often characters change
      changeRate: random(0.01, 0.05),

      // Overall brightness
      opacity: random(0.35, 0.85),
    };
  }

  // =========================
  // CREATE STREAMS
  // =========================

  function createStreams() {
    streams = [];

    columnCount = Math.ceil(
      window.innerWidth / fontSize
    );

    for (let column = 0; column < columnCount; column++) {

      // Use about 90% of available columns
      if (Math.random() > 0.1) {
        streams.push(
          createStream(column)
        );
      }
    }
  }

  // =========================
  // RESIZE CANVAS
  // =========================

  function resizeCanvas() {
    const dpr =
      window.devicePixelRatio || 1;

    canvas.width =
      window.innerWidth * dpr;

    canvas.height =
      window.innerHeight * dpr;

    canvas.style.width =
      `${window.innerWidth}px`;

    canvas.style.height =
      `${window.innerHeight}px`;

    ctx.setTransform(
      dpr,
      0,
      0,
      dpr,
      0,
      0
    );

    createStreams();
  }

  // =========================
  // DRAW ONE STREAM
  // =========================

  function drawStream(stream) {
    const x =
      stream.column * fontSize;

    const headY = stream.y;

    for (
      let i = 0;
      i < stream.length;
      i++
    ) {
      const y =
        headY - i * fontSize;

      // Skip characters outside viewport
      if (
        y < -fontSize ||
        y > window.innerHeight + fontSize
      ) {
        continue;
      }

      // Fade characters as they trail behind
      const position =
        i / stream.length;

      const fade =
        Math.pow(1 - position, 1.5);

      const opacity =
        fade * stream.opacity;

      // Randomly change characters
      if (
        Math.random() <
        stream.changeRate
      ) {
        stream.chars[i] =
          randomCharacter();
      }

      // =========================
      // LEADING CHARACTER
      // =========================

      if (i === 0) {
        ctx.fillStyle = "#ffffff";

        ctx.shadowBlur = 0;
      }

      // =========================
      // TRAILING CHARACTERS
      // =========================

      else {
        ctx.fillStyle =
          `rgba(0, 255, 65, ${opacity})`;

        // No glow on trail
        ctx.shadowBlur = 0;
      }

      ctx.fillText(
        stream.chars[i],
        x,
        y
      );
    }

    ctx.shadowBlur = 0;
  }

  // =========================
  // RESET STREAM
  // =========================

  function resetStream(stream) {
    stream.y =
      random(
        -stream.length * fontSize * 4,
        -fontSize
      );

    stream.length =
      Math.floor(random(10, 35));

    stream.speed =
      random(1.5, 3.5);

    stream.changeRate =
      random(0.01, 0.05);

    stream.opacity =
      random(0.35, 0.85);

    stream.chars =
      Array.from(
        { length: stream.length },
        randomCharacter
      );
  }

  // =========================
  // MAIN ANIMATION
  // =========================

  function draw() {

    // Clear previous frames quickly to keep the characters crisp.
    ctx.fillStyle =
      "rgba(0, 0, 0, 0.3)";

    ctx.fillRect(
      0,
      0,
      window.innerWidth,
      window.innerHeight
    );

    // Crisp monospace characters
    ctx.font =
      `${fontSize}px monospace`;

    ctx.textBaseline =
      "top";

    for (const stream of streams) {

      drawStream(stream);

      // Move stream downward
      stream.y += stream.speed;

      // Restart after leaving screen
      if (
        stream.y -
          stream.length * fontSize >
        window.innerHeight
      ) {
        resetStream(stream);
      }
    }

    requestAnimationFrame(draw);
  }

  // =========================
  // START
  // =========================

  window.addEventListener(
    "resize",
    resizeCanvas
  );

  resizeCanvas();
  draw();
}
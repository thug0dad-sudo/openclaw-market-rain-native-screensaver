(() => {
  const VERSION = "1.6-SAVER";
  const canvas = document.getElementById("rain");
  const ctx = canvas.getContext("2d");

  let speedMultiplier = 1.0;
  let oled = false;
  let streams = [];
  let frame = 0;

  const quotes = ["NVDA", "BTC", "ETH", "RKLB", "LUNR", "ASTS", "PLTR", "SPY", "QQQ"];
  const fontSize = 18;
  const rowHeight = 22;
  const colWidth = 86;
  const trailLength = 24;

  function token() {
    const s = quotes[Math.floor(Math.random() * quotes.length)];
    const r = Math.random();
    if (r < 0.55) return s;
    if (r < 0.75) return s + (Math.random() > 0.5 ? "▲" : "▼");
    if (r < 0.9) return (Math.random() > 0.5 ? "+" : "-") + (Math.random() * 5).toFixed(2) + "%";
    return "$" + (Math.random() * 500).toFixed(2);
  }

  function makeStream(x) {
    return {
      x,
      y: -Math.random() * canvas.height,
      speed: 1.2 + Math.random() * 2.8,
      tokens: Array.from({ length: trailLength }, token),
      drift: Math.random() * 0.6 - 0.3
    };
  }

  function resize() {
    canvas.width = Math.max(800, window.innerWidth || canvas.clientWidth || 800);
    canvas.height = Math.max(600, window.innerHeight || canvas.clientHeight || 600);
    const count = Math.max(12, Math.floor(canvas.width / colWidth));
    streams = Array.from({ length: count }, (_, i) => makeStream(i * colWidth + 12));
  }

  function drawHud() {
    ctx.shadowBlur = 0;
    ctx.font = "14px monospace";
    ctx.fillStyle = "rgba(0,255,90,0.95)";
    ctx.fillText(
      `OpenClaw Market Rain · + Faster · - Slower · 0 Reset · Speed ${speedMultiplier.toFixed(1)}x · Version ${VERSION}`,
      14,
      canvas.height - 22
    );
  }

  function draw() {
    if (!streams.length) resize();

    ctx.fillStyle = oled ? "rgba(0,0,0,0.36)" : "rgba(0,0,0,0.18)";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    ctx.font = `${fontSize}px monospace`;
    ctx.textBaseline = "top";

    for (const stream of streams) {
      stream.y += stream.speed * speedMultiplier;

      if (stream.y - trailLength * rowHeight > canvas.height) {
        Object.assign(stream, makeStream(stream.x));
        stream.y = -Math.random() * 250;
      }

      if (frame % 4 === 0) {
        stream.tokens.pop();
        stream.tokens.unshift(token());
      }

      for (let i = 0; i < stream.tokens.length; i++) {
        const y = stream.y - i * rowHeight;
        if (y < -40 || y > canvas.height + 40) continue;

        const alpha = 1 - i / trailLength;
        if (i === 0) {
          ctx.fillStyle = "rgba(230,255,230,0.98)";
          ctx.shadowColor = "#00ff66";
          ctx.shadowBlur = 12;
        } else {
          ctx.fillStyle = `rgba(0,255,90,${alpha * 0.85})`;
          ctx.shadowBlur = 0;
        }

        ctx.fillText(stream.tokens[i], stream.x + Math.sin((frame + i) / 20) * stream.drift, y);
      }
    }

    drawHud();
    frame++;
  }

  function loop() {
    draw();
    requestAnimationFrame(loop);
  }

  window.__marketRainStart = function () {
    resize();
    draw();
  };

  window.__marketRainFrame = function () {
    draw();
  };

  window.__marketRainResize = function () {
    resize();
  };

  window.addEventListener("resize", resize);
  window.addEventListener("keydown", (e) => {
    if (e.key === "+" || e.key === "=") speedMultiplier = Math.min(5, speedMultiplier + 0.2);
    if (e.key === "-" || e.key === "_") speedMultiplier = Math.max(0.2, speedMultiplier - 0.2);
    if (e.key === "0") speedMultiplier = 1.0;
    if (e.key === "o" || e.key === "O") oled = !oled;
  });

  resize();
  loop();
})();

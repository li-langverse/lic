/**
 * Deterministic reel poses for headless Chrome PNG capture.
 * Query: ?reel_frame=0|1|2 — playhead advance, agent pulse peak, viewport parallax.
 */
(function () {
  var params = new URLSearchParams(window.location.search);
  var raw = params.get("reel_frame");
  if (raw === null || raw === "") return;

  var frame = Math.max(0, Math.min(2, parseInt(raw, 10) || 0));
  document.documentElement.setAttribute("data-reel-frame", String(frame));
  document.documentElement.classList.add("reel-frozen");

  var playhead = document.querySelector(".playhead");
  if (playhead) playhead.style.left = (35 + frame * 10) + "%";

  var grid = document.querySelector(".viewport-grid");
  if (grid) grid.style.transform = "translate(" + frame * 6 + "px, " + frame * 3 + "px)";

  var ring = document.querySelector(".selection-ring");
  if (ring) {
    ring.style.transform =
      "translate(calc(-50% + " + frame * 4 + "px), calc(-50% + " + frame * 2 + "px))";
  }

  var agent = document.querySelector(".agent-status");
  if (agent) agent.classList.toggle("reel-pulse-strong", frame === 1);
})();

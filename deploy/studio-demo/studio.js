/* Li World Studio — interactive demo showcase (visual prototype). */
const canvas = document.getElementById("viewport");
const ctx = canvas.getContext("2d");
const demos = ["rocket", "racing", "robot", "drug", "bioeng", "mmo", "unphysical", "scientific", "publish", "additive", "agent", "play"];
let active = "rocket";
let tick = 0;
let autoReel = false;
let reelIndex = 0;
let reelTimer = null;

/** Canvas palette — synced from CSS --canvas-* tokens per theme. */
let C = {};

function syncCanvasColors() {
  const s = getComputedStyle(document.documentElement);
  const g = (v) => s.getPropertyValue(v).trim();
  C = {
    bg: g("--canvas-bg"),
    elevated: g("--canvas-elevated"),
    surface2: g("--canvas-surface2"),
    border: g("--canvas-border"),
    muted: g("--canvas-muted"),
    text: g("--canvas-text"),
    accent: g("--canvas-accent"),
    pass: g("--canvas-pass"),
    violet: g("--canvas-violet"),
    coral: g("--canvas-coral"),
    greenDark: g("--canvas-green-dark"),
    fail: g("--fail"),
    warn: g("--warn"),
  };
}

function applyTheme(id) {
  document.documentElement.dataset.theme = id;
  syncCanvasColors();
  try {
    localStorage.setItem("li-studio-theme", id);
  } catch (_) {}
  document.querySelectorAll(".theme-btn").forEach((b) => {
    const on = b.dataset.theme === id;
    b.classList.toggle("active", on);
    b.setAttribute("aria-pressed", on ? "true" : "false");
  });
}

const meta = {
  rocket: {
    title: "Rocket — inverse gravity + Lorentz boost",
    profile: "physics.custom + sim_profile_scientific",
    panel: "Custom law: inverse_gravity · γ factor live · Tier-2 heat stub",
    nodes: ["RocketBody", "Nozzle", "Exhaust", "Trajectory"],
  },
  racing: {
    title: "Racing — sim.automotive sensor loop",
    profile: "sim_profile_automotive",
    panel: "LiDAR frames · map load · 60 Hz tick budget",
    nodes: ["Vehicle", "Track", "LiDAR", "HUD"],
  },
  robot: {
    title: "Factory robot — 6-DOF cell + mobile base",
    profile: "sim_profile_robotics",
    panel: "Joint targets · collision proxy · RL env pool",
    nodes: ["Arm", "Gripper", "Conveyor", "Cell"],
  },
  drug: {
    title: "Drug design — Lab-in-the-Loop (LITL)",
    profile: "sim.drug_design + chem",
    panel: "Hypothesis → Generate → DFT/TDDFT · studio.adaptive panels",
    nodes: ["Target", "Ligand", "DFTJob", "Assay"],
  },
  bioeng: {
    title: "Bioengineering — DBTL + bioreactor",
    profile: "bioeng + sim.scientific",
    panel: "Design · Build · Test · Learn · scorecard export",
    nodes: ["Construct", "Bioreactor", "AssayBatch", "Scorecard"],
  },
  mmo: {
    title: "MMORPG — shards, gateway, store replay",
    profile: "sim_profile_mmo + store.realtime",
    panel: "Realm tick · WS session bind · postgres presence",
    nodes: ["Gateway", "Shard0", "Shard1", "PlayerSessions"],
  },
  unphysical: {
    title: "Unphysical game — inverse gravity + teleports",
    profile: "sim_law_mode_arbitrary + physics.custom",
    panel: "Spin-up: game_unphysical · custom_law_id · no tier-2 runtime yet",
    nodes: ["World", "InverseGravity", "TeleportZone", "ArbitraryLaw"],
  },
  scientific: {
    title: "Scientific — reactor field + viz frames",
    profile: "sim.scientific + render viewport",
    panel: "Heat-equation stub · SimVizFrame samples · native binary bridge",
    nodes: ["ReactorField", "SimVizFrame", "HeatStep", "Viewport"],
  },
  publish: {
    title: "Publication export — figures + bundles",
    profile: "studio.publish + PH-PUB",
    panel: "PublishBundle hash · 300 DPI figures · spin-up: publish",
    nodes: ["Figure", "PublishBundle", "ContentHash", "Export"],
  },
  additive: {
    title: "Additive manufacturing — voxel grid",
    profile: "sim_profile_additive + voxel",
    panel: "4×4×4 grid · sim.additive · spin-up: additive",
    nodes: ["VoxelGrid", "Layer", "Slicer", "BuildPlate"],
  },
  agent: {
    title: "Studio agent — lic diagnose + apply_patch",
    profile: "studio.ai + PH-AGENT",
    panel: "JSON diagnose gate · patch_id=2 · spin-up: agent",
    nodes: ["Diagnose", "PatchRequest", "ApplyPatch", "Gate"],
  },
  play: {
    title: "Play mode — new_game_world + new_field",
    profile: "studio_play_mode + world + sim.scientific",
    panel: "start_playing · tick_viewport · publish_repro · spin-up: play_mode",
    nodes: ["GameWorld", "SimField", "Viewport", "PublishBundle"],
  },
};

const WORKSPACE_LABELS = {
  rocket: "Game · viewport",
  racing: "Automotive · viewport",
  robot: "Robotics · viewport",
  drug: "LITL · adaptive",
  bioeng: "Bio · DBTL",
  mmo: "MMO · shards",
  unphysical: "Game · arbitrary laws",
  scientific: "Sim · field view",
  publish: "Publish · figures",
  additive: "Additive · voxel",
  agent: "Agent · diagnose",
  play: "Play · session",
};

function setDemo(name) {
  active = name;
  document.querySelectorAll(".tab").forEach((b) => {
    b.classList.toggle("active", b.dataset.demo === name);
  });
  const m = meta[name];
  document.getElementById("demo-title").textContent = m.title;
  const profileEl = document.getElementById("profile-tag");
  if (profileEl) profileEl.textContent = m.profile;
  const profileCode = document.getElementById("profile-code");
  if (profileCode) profileCode.textContent = m.profile;
  const panel = document.getElementById("panel-content");
  if (panel) panel.textContent = m.panel;
  const ws = document.getElementById("workspace-label");
  if (ws) ws.textContent = WORKSPACE_LABELS[name] || "Studio";
  const ctx = document.getElementById("agent-context");
  if (ctx) ctx.textContent = `world.li · ${m.nodes[0] || "World"}`;
  const list = document.getElementById("outliner-list");
  list.innerHTML = m.nodes.map((n, i) => `<li class="${i === 0 ? "active" : ""}">${n}</li>`).join("");
  if (name === "agent" || name === "scientific") switchRail("agent");
}

function drawRocket(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  const stars = 80;
  ctx.fillStyle = "#fff";
  for (let i = 0; i < stars; i++) {
    const x = (i * 97 + t * 2) % w;
    const y = (i * 53) % (h * 0.6);
    ctx.globalAlpha = 0.3 + (i % 5) * 0.1;
    ctx.fillRect(x, y, 2, 2);
  }
  ctx.globalAlpha = 1;
  const x = w * 0.5 + Math.sin(t * 0.02) * 40;
  const y = h * 0.55 - (t * 1.2) % (h * 0.5);
  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(-0.05);
  ctx.fillStyle = C.elevated;
  ctx.fillRect(-18, -50, 36, 70);
  ctx.fillStyle = C.fail;
  ctx.beginPath();
  ctx.moveTo(0, 30);
  ctx.lineTo(-14, 55);
  ctx.lineTo(14, 55);
  ctx.fill();
  ctx.fillStyle = C.warn;
  ctx.globalAlpha = 0.7 + 0.3 * Math.sin(t * 0.3);
  ctx.beginPath();
  ctx.ellipse(0, 42, 10, 18 + Math.sin(t * 0.4) * 6, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();
  ctx.fillStyle = C.accent;
  ctx.font = "14px monospace";
  ctx.fillText(`γ ≈ ${(1.02 + 0.01 * Math.sin(t * 0.05)).toFixed(3)}`, 24, h - 40);
}

function drawRacing(t) {
  const w = canvas.width;
  const h = canvas.height;
  const grad = ctx.createLinearGradient(0, 0, 0, h);
  grad.addColorStop(0, C.greenDark);
  grad.addColorStop(1, C.bg);
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);
  ctx.strokeStyle = C.border;
  ctx.lineWidth = 4;
  for (let i = 0; i < 12; i++) {
    const y = h * 0.35 + i * 28;
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(w, y + Math.sin(i) * 8);
    ctx.stroke();
  }
  const carX = (t * 4) % (w + 100) - 50;
  ctx.fillStyle = C.fail;
  ctx.fillRect(carX, h * 0.55, 90, 28);
  ctx.fillStyle = C.surface2;
  ctx.fillRect(carX + 15, h * 0.52, 40, 18);
  ctx.fillStyle = C.pass;
  ctx.font = "12px monospace";
  ctx.fillText(`LiDAR frame ${Math.floor(t / 10) % 1000}`, 24, 32);
}

function drawRobot(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.elevated;
  ctx.fillRect(0, 0, w, h);
  const bx = w * 0.35;
  const by = h * 0.7;
  ctx.strokeStyle = C.accent;
  ctx.lineWidth = 8;
  ctx.lineCap = "round";
  let angle = Math.sin(t * 0.03) * 0.8;
  let x = bx;
  let y = by;
  const segs = [80, 70, 55, 40];
  for (const len of segs) {
    const nx = x + Math.cos(angle) * len;
    const ny = y - Math.sin(angle) * len;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(nx, ny);
    ctx.stroke();
    x = nx;
    y = ny;
    angle += 0.6 + Math.sin(t * 0.02) * 0.2;
  }
  ctx.fillStyle = C.coral;
  ctx.beginPath();
  ctx.arc(x, y, 14, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = C.elevated;
  ctx.font = "13px sans-serif";
  ctx.fillText("6-DOF · mobile base", 24, h - 30);
}

function drawDrug(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  const cx = w / 2;
  const cy = h / 2;
  const stages = ["Hypothesis", "Generate", "DFT", "Assay"];
  const stage = Math.floor(t / 90) % 4;
  stages.forEach((s, i) => {
    const x = 80 + i * ((w - 160) / 3);
    ctx.fillStyle = i === stage ? C.accent : C.border;
    ctx.fillRect(x - 40, 40, 80, 36);
    ctx.fillStyle = "#fff";
    ctx.font = "12px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(s, x, 64);
  });
  ctx.textAlign = "left";
  const n = 8;
  for (let i = 0; i < n; i++) {
    const a = (i / n) * Math.PI * 2 + t * 0.02;
    const r = 60 + Math.sin(t * 0.05 + i) * 10;
    ctx.fillStyle = i % 2 ? C.pass : C.violet;
    ctx.beginPath();
    ctx.arc(cx + Math.cos(a) * r, cy + Math.sin(a) * r * 0.6, 12, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.strokeStyle = C.accent;
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.arc(cx, cy, 100, 0, Math.PI * 2);
  ctx.stroke();
  ctx.fillStyle = C.elevated;
  ctx.fillText(`E = ${(-124.5 - Math.sin(t * 0.01) * 2).toFixed(2)} Ha (stub)`, 24, h - 24);
}

function drawBioeng(t) {
  const w = canvas.width;
  const h = canvas.height;
  drawDrug(t);
  ctx.fillStyle = "rgba(94, 224, 168, 0.15)";
  ctx.fillRect(0, h * 0.75, w, h * 0.25);
  ctx.fillStyle = C.pass;
  ctx.font = "13px monospace";
  ctx.fillText("Bioreactor T=37°C · DBTL iteration " + Math.floor(t / 60), 24, h - 50);
}

function drawScientific(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  const cols = 16;
  const rows = 10;
  const cw = (w - 80) / cols;
  const ch = (h - 120) / rows;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const heat = 0.5 + 0.5 * Math.sin(t * 0.03 + c * 0.4 + r * 0.6);
      const red = Math.floor(80 + heat * 175);
      const blue = Math.floor(40 + (1 - heat) * 120);
      ctx.fillStyle = `rgb(${red},${Math.floor(heat * 80)},${blue})`;
      ctx.fillRect(40 + c * cw, 60 + r * ch, cw - 2, ch - 2);
    }
  }
  ctx.fillStyle = C.accent;
  ctx.font = "13px monospace";
  ctx.fillText(`T=37.${(t % 10)}°C · timestep ${Math.floor(t / 3)}`, 24, h - 36);
}

function drawUnphysical(t) {
  const w = canvas.width;
  const h = canvas.height;
  const grad = ctx.createLinearGradient(0, h, 0, 0);
  grad.addColorStop(0, C.elevated);
  grad.addColorStop(1, C.bg);
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);
  ctx.strokeStyle = C.border;
  ctx.setLineDash([8, 8]);
  ctx.strokeRect(40, h * 0.72, w - 80, 2);
  ctx.setLineDash([]);
  ctx.fillStyle = C.elevated;
  ctx.font = "12px monospace";
  ctx.fillText("ground (objects fall up)", 48, h * 0.72 - 8);
  const n = 24;
  for (let i = 0; i < n; i++) {
    const px = 60 + (i * 47 + t * 3) % (w - 120);
    const py = h * 0.65 - ((t * 2 + i * 31) % 280);
    ctx.fillStyle = i % 4 === 0 ? C.violet : C.accent;
    ctx.beginPath();
    ctx.arc(px, py, 6 + (i % 3), 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.fillStyle = C.coral;
  ctx.fillRect(w * 0.5 - 40, h * 0.25, 80, 50);
  ctx.fillStyle = "#fff";
  ctx.font = "11px sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("TELEPORT", w * 0.5, h * 0.25 + 30);
  ctx.textAlign = "left";
  ctx.fillStyle = C.pass;
  ctx.fillText(`law_mode=arbitrary · custom_law_id=1`, 24, h - 40);
}

function drawPlay(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  const n = 24;
  for (let i = 0; i < n; i++) {
    const px = 80 + (i % 6) * 90 + Math.sin(t * 0.03 + i) * 12;
    const py = 140 + Math.floor(i / 6) * 70 + Math.cos(t * 0.04 + i) * 8;
    ctx.fillStyle = i % 4 === 0 ? C.accent : C.pass;
    ctx.beginPath();
    ctx.arc(px, py, 10, 0, Math.PI * 2);
    ctx.fill();
  }
  const gx = w * 0.62;
  const gy = h * 0.35;
  const gw = w * 0.28;
  const gh = h * 0.45;
  const grad = ctx.createLinearGradient(gx, gy, gx + gw, gy + gh);
  grad.addColorStop(0, C.accent);
  grad.addColorStop(1, C.violet);
  ctx.fillStyle = grad;
  ctx.fillRect(gx, gy, gw, gh);
  ctx.strokeStyle = C.border;
  ctx.strokeRect(gx, gy, gw, gh);
  ctx.fillStyle = C.coral;
  ctx.beginPath();
  ctx.arc(w * 0.5, h * 0.72, 36, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#000";
  ctx.font = "bold 16px sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("▶", w * 0.5, h * 0.72 + 6);
  ctx.textAlign = "left";
  ctx.fillStyle = C.elevated;
  ctx.font = "13px monospace";
  ctx.fillText("new_game_world · new_field · start_playing", 24, h - 48);
  ctx.fillText(`tick ${Math.floor(t / 2)} · spin-up: play_mode`, 24, h - 28);
}

function drawAgent(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  ctx.fillStyle = C.elevated;
  ctx.fillRect(60, 80, w - 120, h - 200);
  ctx.strokeStyle = C.pass;
  ctx.strokeRect(60, 80, w - 120, h - 200);
  const lines = [
    "{ \"ok\": true, \"errors\": 0 }",
    "patch_id: 2 · lines: 4",
    "studio_ai_apply_if_clean ✓",
    "lic check --format=json",
  ];
  ctx.font = "14px monospace";
  lines.forEach((line, i) => {
    ctx.fillStyle = i === 0 ? C.pass : C.muted;
    ctx.fillText(line, 80, 120 + i * 28);
  });
  ctx.fillStyle = C.accent;
  ctx.fillText(`tick ${Math.floor(t / 2)} · agent gate clear`, 80, h - 120);
}

function drawAdditive(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  const size = 4;
  const cell = 36;
  const ox = w * 0.5 - (size * cell) / 2;
  const oy = h * 0.45 - (size * cell) / 2;
  for (let z = 0; z < size; z++) {
    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        const idx = x + y * size + z * size * size;
        const on = (idx + Math.floor(t / 8)) % 5 !== 0;
        if (!on) continue;
        const px = ox + x * cell + z * 4;
        const py = oy + y * cell - z * 6;
        ctx.fillStyle = `hsl(${200 + idx * 8}, 70%, ${45 + z * 8}%)`;
        ctx.fillRect(px, py, cell - 2, cell - 2);
      }
    }
  }
  ctx.fillStyle = C.elevated;
  ctx.font = "13px monospace";
  ctx.fillText("voxel 4³ · profile=sim_profile_additive", 24, h - 36);
}

function drawPublish(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  ctx.fillStyle = C.elevated;
  ctx.fillRect(80, 80, w - 160, h - 160);
  ctx.strokeStyle = C.border;
  ctx.strokeRect(80, 80, w - 160, h - 160);
  ctx.fillStyle = C.accent;
  ctx.font = "bold 18px sans-serif";
  ctx.fillText("Figure 1 — World Studio export", 120, 120);
  const bars = 8;
  for (let i = 0; i < bars; i++) {
    const bh = 40 + Math.sin(t * 0.04 + i) * 30 + 80;
    ctx.fillStyle = i % 2 === 0 ? C.pass : C.violet;
    ctx.fillRect(140 + i * 110, h - 180 - bh, 70, bh);
  }
  ctx.fillStyle = C.elevated;
  ctx.font = "13px monospace";
  ctx.fillText(`PublishBundle hash=3291 · dpi=300 · files=3`, 120, h - 100);
  ctx.fillStyle = C.coral;
  ctx.fillRect(w - 200, 100, 120, 36);
  ctx.fillStyle = "#000";
  ctx.font = "12px sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("Export PDF", w - 140, 122);
  ctx.textAlign = "left";
}

function drawMmo(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = C.bg;
  ctx.fillRect(0, 0, w, h);
  const shards = 2;
  for (let s = 0; s < shards; s++) {
    const ox = s * (w / 2);
    ctx.strokeStyle = C.border;
    ctx.strokeRect(ox + 20, 60, w / 2 - 40, h - 120);
    ctx.fillStyle = C.accent;
    ctx.font = "bold 14px sans-serif";
    ctx.fillText(`Shard ${s}`, ox + 32, 88);
    for (let p = 0; p < 12; p++) {
      const px = ox + 40 + (p % 4) * 70;
      const py = 120 + Math.floor(p / 4) * 50 + Math.sin(t * 0.05 + p + s) * 5;
      ctx.fillStyle = p % 3 === 0 ? C.pass : C.muted;
      ctx.fillRect(px, py, 20, 20);
    }
  }
  ctx.fillStyle = C.coral;
  ctx.fillRect(w / 2 - 50, 20, 100, 30);
  ctx.fillStyle = "#000";
  ctx.font = "12px sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("Gateway", w / 2, 40);
  ctx.textAlign = "left";
  ctx.fillStyle = C.elevated;
  ctx.fillText(`tick ${Math.floor(t / 2)} · realm dev-realm-1`, 24, h - 24);
}

const drawers = {
  rocket: drawRocket,
  racing: drawRacing,
  robot: drawRobot,
  drug: drawDrug,
  bioeng: drawBioeng,
  mmo: drawMmo,
  unphysical: drawUnphysical,
  scientific: drawScientific,
  publish: drawPublish,
  additive: drawAdditive,
  agent: drawAgent,
  play: drawPlay,
};

function frame() {
  tick++;
  document.getElementById("tick").textContent = `tick ${tick}`;
  drawers[active](tick);
  requestAnimationFrame(frame);
}

document.querySelectorAll(".tab").forEach((btn) => {
  btn.addEventListener("click", () => setDemo(btn.dataset.demo));
});

document.getElementById("btn-auto").addEventListener("click", () => {
  autoReel = !autoReel;
  document.getElementById("btn-auto").textContent = autoReel ? "⏸ Pause reel" : "▶ Demo reel";
  if (autoReel && !reelTimer) {
    reelTimer = setInterval(() => {
      reelIndex = (reelIndex + 1) % demos.length;
      setDemo(demos[reelIndex]);
    }, 8000);
  }
  if (!autoReel && reelTimer) {
    clearInterval(reelTimer);
    reelTimer = null;
  }
});

/** Agent-first command registry (maps to li-ui ui_cmd_* / studio_command_execute). */
const COMMANDS = [
  { id: 1, name: "Play", hint: "lic build && start_playing", keys: "⌘P" },
  { id: 2, name: "Pause", hint: "stop_playing", keys: "" },
  { id: 3, name: "Build", hint: "lic build packages/…", keys: "⌘B" },
  { id: 4, name: "Apply patch", hint: "studio.ai apply_if_clean", keys: "" },
  { id: 5, name: "Open world.li", hint: "focus world spawn", keys: "⌘O" },
];

const paletteEl = document.getElementById("command-palette");
const paletteInput = document.getElementById("palette-input");
const paletteList = document.getElementById("palette-list");
const agentChat = document.getElementById("agent-chat");

function nowLabel() {
  const d = new Date();
  return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
}

function renderPlanCard(steps) {
  const items = steps
    .map((s) => {
      const cls = s.state === "done" ? "done" : s.state === "active" ? "active" : "";
      const icon = s.state === "done" ? "✓" : s.state === "active" ? "◎" : "○";
      return `<li class="${cls}"><span class="step-icon">${icon}</span><span>${s.text}</span></li>`;
    })
    .join("");
  return `<div class="plan-card"><h4>Plan</h4><ul class="plan-steps">${items}</ul></div>`;
}

function renderMessage({ role, text, time, plan, actions, gate }) {
  const wrap = document.createElement("article");
  wrap.className = `msg msg-${role}`;
  const meta = document.createElement("div");
  meta.className = "msg-meta";
  if (role !== "system") {
    meta.innerHTML = `<span class="msg-role">${role}</span><span>${time || nowLabel()}</span>`;
  }
  const bubble = document.createElement("div");
  bubble.className = "msg-bubble";
  bubble.textContent = text;
  wrap.appendChild(meta);
  wrap.appendChild(bubble);
  if (plan && plan.length) {
    const planEl = document.createElement("div");
    planEl.innerHTML = renderPlanCard(plan);
    wrap.appendChild(planEl.firstElementChild);
  }
  if (gate) {
    const g = document.createElement("div");
    g.className = "gate-inline";
    g.textContent = gate;
    wrap.appendChild(g);
  }
  if (actions && actions.length) {
    const row = document.createElement("div");
    row.className = "msg-actions";
    actions.forEach((a) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = a.label;
      btn.className = a.kind === "apply" ? "btn-apply" : a.kind === "reject" ? "btn-reject" : "btn-secondary";
      if (a.cmd) btn.addEventListener("click", () => runCommand(a.cmd));
      row.appendChild(btn);
    });
    wrap.appendChild(row);
  }
  return wrap;
}

function appendTranscript(role, text, extras = {}) {
  if (!agentChat) return;
  agentChat.appendChild(renderMessage({ role, text, ...extras }));
  agentChat.scrollTop = agentChat.scrollHeight;
}

function switchRail(which) {
  document.querySelectorAll(".rail-tab").forEach((t) => {
    const on = t.dataset.rail === which;
    t.classList.toggle("active", on);
    t.setAttribute("aria-selected", on ? "true" : "false");
  });
  const agentDock = document.getElementById("agent-dock");
  const inspectorDock = document.getElementById("inspector-dock");
  if (agentDock) {
    agentDock.classList.toggle("hidden", which !== "agent");
    agentDock.hidden = which !== "agent";
  }
  if (inspectorDock) {
    inspectorDock.classList.toggle("hidden", which !== "inspector");
    inspectorDock.hidden = which !== "inspector";
  }
}

document.querySelectorAll(".rail-tab").forEach((btn) => {
  btn.addEventListener("click", () => switchRail(btn.dataset.rail));
});

document.querySelectorAll(".hint-chip").forEach((chip) => {
  chip.addEventListener("click", () => {
    const input = document.getElementById("agent-input");
    if (input) {
      input.value = chip.dataset.hint + " ";
      input.focus();
    }
  });
});

function renderPalette(filter) {
  const q = (filter || "").toLowerCase();
  paletteList.innerHTML = COMMANDS.filter(
    (c) => c.name.toLowerCase().includes(q) || String(c.id).includes(q)
  )
    .map(
      (c) =>
        `<li data-cmd="${c.id}"><span>${c.name}</span><span class="cmd-id">ui_cmd_${c.id} · ${c.hint}</span></li>`
    )
    .join("");
}

function openPalette() {
  paletteEl.classList.remove("hidden");
  renderPalette("");
  paletteInput.value = "";
  paletteInput.focus();
}

function closePalette() {
  paletteEl.classList.add("hidden");
}

function runCommand(id) {
  const c = COMMANDS.find((x) => x.id === id);
  if (!c) return;
  closePalette();
  appendTranscript("system", `ui_cmd_${id} · ${c.name} → ${c.hint}`);
  if (id === 1) {
    appendTranscript("agent", "Play session armed. Viewport tick started after gate.", {
      gate: "lic build · PASS · composable compile_ok",
    });
    setDemo("play");
  }
  if (id === 3) {
    appendTranscript("agent", "Build finished — 112 composable gates green (stub).", {
      gate: "lic build · PASS",
      plan: [
        { text: "Resolve packages/world", state: "done" },
        { text: "Link sim + physics.runtime", state: "done" },
        { text: "Emit compile_ok smoke", state: "active" },
      ],
    });
    const chip = document.getElementById("gate-chip");
    if (chip) chip.innerHTML = '<span class="chip-dot"></span>lic build · PASS';
  }
  if (id === 4) {
    appendTranscript("agent", "Diagnose clean. Patch touches world.li spawn + sim profile.", {
      plan: [
        { text: "studio.ai diagnose", state: "done" },
        { text: "Preview diff (patch_id=2)", state: "done" },
        { text: "Await human apply", state: "active" },
      ],
      actions: [
        { label: "Apply patch", kind: "apply", cmd: 4 },
        { label: "Reject", kind: "reject" },
        { label: "Show diff", kind: "secondary" },
      ],
      gate: "lic_gate=1 · target_hash=8f2a…",
    });
  }
  if (id === 5) setDemo("play");
}

paletteList.addEventListener("click", (e) => {
  const li = e.target.closest("li[data-cmd]");
  if (li) runCommand(Number(li.dataset.cmd));
});

paletteInput.addEventListener("input", () => renderPalette(paletteInput.value));
paletteInput.addEventListener("keydown", (e) => {
  if (e.key === "Escape") closePalette();
  if (e.key === "Enter") {
    const first = paletteList.querySelector("li[data-cmd]");
    if (first) runCommand(Number(first.dataset.cmd));
  }
});

document.getElementById("btn-palette").addEventListener("click", openPalette);
document.addEventListener("keydown", (e) => {
  if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
    e.preventDefault();
    if (paletteEl.classList.contains("hidden")) openPalette();
    else closePalette();
  }
});

document.getElementById("agent-form").addEventListener("submit", (e) => {
  e.preventDefault();
  const input = document.getElementById("agent-input");
  const msg = (input.value || "").trim();
  if (!msg) return;
  appendTranscript("user", msg);
  input.value = "";
  const lower = msg.toLowerCase();
  if (lower.startsWith("/build") || lower.includes("lic build")) {
    runCommand(3);
    return;
  }
  if (lower.startsWith("/patch") || lower.includes("apply")) {
    runCommand(4);
    return;
  }
  appendTranscript("agent", "I'll search world.li, propose a patch, then run lic build and bench.", {
    plan: [
      { text: "Read world.li + manifests", state: "done" },
      { text: "Draft patch (studio.ai)", state: "active" },
      { text: "lic build + tier-2 bench", state: "pending" },
      { text: "Surface validity in chrome", state: "pending" },
    ],
    actions: [
      { label: "Apply patch", kind: "apply", cmd: 4 },
      { label: "Reject", kind: "reject" },
    ],
    gate: "awaiting lic_gate",
  });
  appendTranscript("system", "UiAgentAction · panel_slot=agent_dock · replay=typed");
});

function seedAgentChat() {
  appendTranscript("system", "ui_layout_agent_first · transcript roles enabled");
  appendTranscript("agent", "Ready. I can edit Li packages, run gates, and show proof in the toolbar.", {
    plan: [
      { text: "⌘K or /build — lic build gate", state: "done" },
      { text: "Chat plan → apply with PASS chip", state: "active" },
      { text: "Bench + validity on engineering profiles", state: "pending" },
    ],
  });
  appendTranscript("user", "Bump rocket spawn height and verify composable build.");
  appendTranscript("agent", "Found RocketBody in world.li. Proposing +12m on spawn Z.", {
    plan: [
      { text: "Parse world.li hierarchy", state: "done" },
      { text: "Generate patch_id=2", state: "done" },
      { text: "Run lic build (stub)", state: "active" },
    ],
    actions: [
      { label: "Apply patch", kind: "apply", cmd: 4 },
      { label: "Reject", kind: "reject" },
      { label: "Open diff", kind: "secondary" },
    ],
    gate: "diagnose ok=1",
  });
}

seedAgentChat();

syncCanvasColors();
const savedTheme = (() => {
  try {
    return localStorage.getItem("li-studio-theme");
  } catch (_) {
    return null;
  }
})();
if (savedTheme && ["aurora", "ember", "slate"].includes(savedTheme)) {
  applyTheme(savedTheme);
} else {
  syncCanvasColors();
}
document.querySelectorAll(".theme-btn").forEach((btn) => {
  btn.addEventListener("click", () => applyTheme(btn.dataset.theme));
});

const params = new URLSearchParams(location.search);
if (params.get("autoreel") === "1") {
  document.getElementById("btn-auto").click();
}
if (params.get("demo")) setDemo(params.get("demo"));

setDemo(active);
requestAnimationFrame(frame);

fetch("status.json")
  .then((r) => (r.ok ? r.json() : null))
  .then((s) => {
    if (!s) return;
    const el = document.getElementById("gate-count");
    if (el) {
      el.textContent = `${s.composable_gates} composable · ${s.game_dev_gates} game_dev · ${s.vertical_demo_builds} builds`;
    }
    const st = document.getElementById("lic-status");
    if (st) {
      const gpu = s.gpu_viewport ? " · GPU viewport" : "";
      const pub = s.publish_template ? " · publish" : "";
      const milestone =
        s.milestone_composable_gates >= 121 ? ` · ${s.milestone_composable_gates} gates` : "";
      st.textContent = `lic ✓ · ${s.sprint} · ${s.branch}${gpu}${pub}${milestone}`;
    }
  })
  .catch(() => {});

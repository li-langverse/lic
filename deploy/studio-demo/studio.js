/* Li World Studio — interactive demo showcase (visual prototype). */
const canvas = document.getElementById("viewport");
const ctx = canvas.getContext("2d");
const demos = ["rocket", "racing", "robot", "drug", "bioeng", "mmo", "unphysical", "scientific"];
let active = "rocket";
let tick = 0;
let autoReel = false;
let reelIndex = 0;
let reelTimer = null;

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
};

function setDemo(name) {
  active = name;
  document.querySelectorAll(".tab").forEach((b) => {
    b.classList.toggle("active", b.dataset.demo === name);
  });
  const m = meta[name];
  document.getElementById("demo-title").textContent = m.title;
  document.getElementById("profile-tag").textContent = m.profile;
  document.getElementById("panel-content").textContent = m.panel;
  const list = document.getElementById("outliner-list");
  list.innerHTML = m.nodes.map((n, i) => `<li class="${i === 0 ? "active" : ""}">${n}</li>`).join("");
}

function drawRocket(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = "#010409";
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
  ctx.fillStyle = "#8b949e";
  ctx.fillRect(-18, -50, 36, 70);
  ctx.fillStyle = "#f85149";
  ctx.beginPath();
  ctx.moveTo(0, 30);
  ctx.lineTo(-14, 55);
  ctx.lineTo(14, 55);
  ctx.fill();
  ctx.fillStyle = "#ffa657";
  ctx.globalAlpha = 0.7 + 0.3 * Math.sin(t * 0.3);
  ctx.beginPath();
  ctx.ellipse(0, 42, 10, 18 + Math.sin(t * 0.4) * 6, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();
  ctx.fillStyle = "#58a6ff";
  ctx.font = "14px monospace";
  ctx.fillText(`γ ≈ ${(1.02 + 0.01 * Math.sin(t * 0.05)).toFixed(3)}`, 24, h - 40);
}

function drawRacing(t) {
  const w = canvas.width;
  const h = canvas.height;
  const grad = ctx.createLinearGradient(0, 0, 0, h);
  grad.addColorStop(0, "#1a472a");
  grad.addColorStop(1, "#0d1117");
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);
  ctx.strokeStyle = "#30363d";
  ctx.lineWidth = 4;
  for (let i = 0; i < 12; i++) {
    const y = h * 0.35 + i * 28;
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(w, y + Math.sin(i) * 8);
    ctx.stroke();
  }
  const carX = (t * 4) % (w + 100) - 50;
  ctx.fillStyle = "#ff6b6b";
  ctx.fillRect(carX, h * 0.55, 90, 28);
  ctx.fillStyle = "#21262d";
  ctx.fillRect(carX + 15, h * 0.52, 40, 18);
  ctx.fillStyle = "#3fb950";
  ctx.font = "12px monospace";
  ctx.fillText(`LiDAR frame ${Math.floor(t / 10) % 1000}`, 24, 32);
}

function drawRobot(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = "#161b22";
  ctx.fillRect(0, 0, w, h);
  const bx = w * 0.35;
  const by = h * 0.7;
  ctx.strokeStyle = "#58a6ff";
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
  ctx.fillStyle = "#f0883e";
  ctx.beginPath();
  ctx.arc(x, y, 14, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#8b949e";
  ctx.font = "13px sans-serif";
  ctx.fillText("6-DOF · mobile base", 24, h - 30);
}

function drawDrug(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = "#0d1117";
  ctx.fillRect(0, 0, w, h);
  const cx = w / 2;
  const cy = h / 2;
  const stages = ["Hypothesis", "Generate", "DFT", "Assay"];
  const stage = Math.floor(t / 90) % 4;
  stages.forEach((s, i) => {
    const x = 80 + i * ((w - 160) / 3);
    ctx.fillStyle = i === stage ? "#58a6ff" : "#30363d";
    ctx.fillRect(x - 40, 40, 80, 36);
    ctx.fillStyle = "#e6edf3";
    ctx.font = "12px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(s, x, 64);
  });
  ctx.textAlign = "left";
  const n = 8;
  for (let i = 0; i < n; i++) {
    const a = (i / n) * Math.PI * 2 + t * 0.02;
    const r = 60 + Math.sin(t * 0.05 + i) * 10;
    ctx.fillStyle = i % 2 ? "#3fb950" : "#a371f7";
    ctx.beginPath();
    ctx.arc(cx + Math.cos(a) * r, cy + Math.sin(a) * r * 0.6, 12, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.strokeStyle = "#58a6ff";
  ctx.lineWidth = 2;
  ctx.beginPath();
  ctx.arc(cx, cy, 100, 0, Math.PI * 2);
  ctx.stroke();
  ctx.fillStyle = "#8b949e";
  ctx.fillText(`E = ${(-124.5 - Math.sin(t * 0.01) * 2).toFixed(2)} Ha (stub)`, 24, h - 24);
}

function drawBioeng(t) {
  const w = canvas.width;
  const h = canvas.height;
  drawDrug(t);
  ctx.fillStyle = "rgba(63, 185, 80, 0.15)";
  ctx.fillRect(0, h * 0.75, w, h * 0.25);
  ctx.fillStyle = "#3fb950";
  ctx.font = "13px monospace";
  ctx.fillText("Bioreactor T=37°C · DBTL iteration " + Math.floor(t / 60), 24, h - 50);
}

function drawScientific(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = "#0d1117";
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
  ctx.fillStyle = "#58a6ff";
  ctx.font = "13px monospace";
  ctx.fillText(`T=37.${(t % 10)}°C · timestep ${Math.floor(t / 3)}`, 24, h - 36);
}

function drawUnphysical(t) {
  const w = canvas.width;
  const h = canvas.height;
  const grad = ctx.createLinearGradient(0, h, 0, 0);
  grad.addColorStop(0, "#161b22");
  grad.addColorStop(1, "#0d1117");
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);
  ctx.strokeStyle = "#30363d";
  ctx.setLineDash([8, 8]);
  ctx.strokeRect(40, h * 0.72, w - 80, 2);
  ctx.setLineDash([]);
  ctx.fillStyle = "#8b949e";
  ctx.font = "12px monospace";
  ctx.fillText("ground (objects fall up)", 48, h * 0.72 - 8);
  const n = 24;
  for (let i = 0; i < n; i++) {
    const px = 60 + (i * 47 + t * 3) % (w - 120);
    const py = h * 0.65 - ((t * 2 + i * 31) % 280);
    ctx.fillStyle = i % 4 === 0 ? "#a371f7" : "#58a6ff";
    ctx.beginPath();
    ctx.arc(px, py, 6 + (i % 3), 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.fillStyle = "#f0883e";
  ctx.fillRect(w * 0.5 - 40, h * 0.25, 80, 50);
  ctx.fillStyle = "#fff";
  ctx.font = "11px sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("TELEPORT", w * 0.5, h * 0.25 + 30);
  ctx.textAlign = "left";
  ctx.fillStyle = "#3fb950";
  ctx.fillText(`law_mode=arbitrary · custom_law_id=1`, 24, h - 40);
}

function drawMmo(t) {
  const w = canvas.width;
  const h = canvas.height;
  ctx.fillStyle = "#0d1117";
  ctx.fillRect(0, 0, w, h);
  const shards = 2;
  for (let s = 0; s < shards; s++) {
    const ox = s * (w / 2);
    ctx.strokeStyle = "#30363d";
    ctx.strokeRect(ox + 20, 60, w / 2 - 40, h - 120);
    ctx.fillStyle = "#58a6ff";
    ctx.font = "bold 14px sans-serif";
    ctx.fillText(`Shard ${s}`, ox + 32, 88);
    for (let p = 0; p < 12; p++) {
      const px = ox + 40 + (p % 4) * 70;
      const py = 120 + Math.floor(p / 4) * 50 + Math.sin(t * 0.05 + p + s) * 5;
      ctx.fillStyle = p % 3 === 0 ? "#3fb950" : "#8b949e";
      ctx.fillRect(px, py, 20, 20);
    }
  }
  ctx.fillStyle = "#f0883e";
  ctx.fillRect(w / 2 - 50, 20, 100, 30);
  ctx.fillStyle = "#000";
  ctx.font = "12px sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("Gateway", w / 2, 40);
  ctx.textAlign = "left";
  ctx.fillStyle = "#8b949e";
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
    if (st) st.textContent = `lic ✓ · ${s.sprint} · ${s.branch}`;
  })
  .catch(() => {});

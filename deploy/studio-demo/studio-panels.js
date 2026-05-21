/* Bottom + side panels: problems, terminal, inspector, assets, timeline (wireframe). */
(function (global) {
  let activeBottom = "problems";
  let selectedEntity = "RocketBody";

  function initPanels() {
    renderProblems();
    renderAssets();
    renderInspector(selectedEntity);
    appendTerminal("$ lic build packages/world\n  composable compile_ok · 112 gates PASS\n");
    bindBottomTabs();
    bindLeftRailTabs();
    bindInspector();
    bindDiffActions();
    bindContextChips();
  }

  function bindBottomTabs() {
    document.querySelectorAll(".bottom-tab").forEach((btn) => {
      btn.addEventListener("click", () => switchBottom(btn.dataset.bottom));
    });
  }

  function switchBottom(id) {
    activeBottom = id;
    document.querySelectorAll(".bottom-tab").forEach((b) => {
      const on = b.dataset.bottom === id;
      b.classList.toggle("active", on);
      b.setAttribute("aria-selected", on ? "true" : "false");
    });
    document.querySelectorAll("[data-bottom-panel]").forEach((p) => {
      const on = p.dataset.bottomPanel === id;
      p.classList.toggle("hidden", !on);
      p.hidden = !on;
    });
  }

  function bindLeftRailTabs() {
    document.querySelectorAll(".left-rail-tab").forEach((btn) => {
      btn.addEventListener("click", () => {
        const id = btn.dataset.leftPanel;
        document.querySelectorAll(".left-rail-tab").forEach((b) => {
          b.classList.toggle("active", b.dataset.leftPanel === id);
        });
        document.querySelectorAll("[data-left-panel]").forEach((p) => {
          const on = p.dataset.leftPanel === id;
          p.classList.toggle("hidden", !on);
        });
      });
    });
  }

  function renderProblems() {
    const list = document.getElementById("problems-list");
    if (!list) return;
    list.innerHTML = StudioFiles.PROBLEMS.map(
      (p) =>
        `<li class="problem-row problem-${p.severity}" data-file="${p.file}" data-line="${p.line}" tabindex="0">
          <span class="problem-sev">${p.severity}</span>
          <span class="problem-code mono">${p.code}</span>
          <span class="problem-msg">${p.message}</span>
          <span class="problem-loc mono">${p.file}:${p.line}</span>
        </li>`
    ).join("");
    list.querySelectorAll(".problem-row").forEach((row) => {
      row.addEventListener("click", () => {
        global.StudioEditor?.openFile(row.dataset.file, Number(row.dataset.line));
        switchBottom("problems");
      });
    });
  }

  function renderAssets() {
    const list = document.getElementById("assets-list");
    if (!list) return;
    list.innerHTML = StudioFiles.ASSETS.map(
      (a) =>
        `<li class="asset-row"><span class="asset-type">${a.type}</span><span>${a.name}</span><span class="asset-size mono">${a.size}</span></li>`
    ).join("");
  }

  function renderInspector(entity) {
    selectedEntity = entity;
    const form = document.getElementById("inspector-form");
    if (!form) return;
    const schema =
      StudioFiles.INSPECTOR_SCHEMA[entity] || StudioFiles.INSPECTOR_SCHEMA.default;
    form.innerHTML = schema
      .map(
        (f) => `<label class="inspector-field">
          <span class="inspector-label">${f.label}${f.unit ? ` (${f.unit})` : ""}</span>
          <input type="text" name="${f.key}" value="${f.value}" data-type="${f.type}" />
        </label>`
      )
      .join("");
    const title = document.getElementById("inspector-title");
    if (title) title.textContent = entity;
  }

  function bindInspector() {
    document.getElementById("outliner-list")?.addEventListener("click", (e) => {
      const li = e.target.closest("li");
      if (!li) return;
      document.querySelectorAll("#outliner-list li").forEach((n) => n.classList.remove("active"));
      li.classList.add("active");
      const name = li.textContent.trim();
      renderInspector(name);
      global.switchRail?.("inspector");
    });
  }

  function appendTerminal(line) {
    const el = document.getElementById("terminal-output");
    if (!el) return;
    el.textContent += `${line}\n`;
    el.scrollTop = el.scrollHeight;
  }

  function bindDiffActions() {
    document.getElementById("diff-apply")?.addEventListener("click", () => {
      global.StudioEditor?.applyPatch();
      global.runCommand?.(3);
      appendTerminal("$ studio.ai apply_patch --patch_id=2\n  lic_gate=PASS");
    });
    document.getElementById("diff-close")?.addEventListener("click", () => global.StudioEditor?.hideDiff());
  }

  function bindContextChips() {
    document.getElementById("btn-at-file")?.addEventListener("click", () => {
      const path = global.StudioEditor?.getActivePath() || "world.li";
      insertComposerChip(`@${path}`);
    });
  }

  function insertComposerChip(text) {
    const input = document.getElementById("agent-input");
    if (!input) return;
    const chips = document.getElementById("composer-chips");
    if (chips) {
      const span = document.createElement("span");
      span.className = "context-chip mono";
      span.textContent = text;
      chips.appendChild(span);
    }
    input.value = `${input.value.trim()} ${text} `.trim() + " ";
    input.focus();
  }

  function showTimelineForDemo(demo) {
    const el = document.getElementById("timeline-strip");
    if (!el) return;
    if (demo === "publish" || demo === "rocket") {
      el.innerHTML = `<div class="timeline-track"><span class="tl-key active">▶</span><span class="tl-shot">Shot 1</span><span class="tl-shot">Shot 2</span><span class="tl-shot muted">MRQ export</span></div>`;
    } else if (demo === "drug" || demo === "bioeng") {
      el.innerHTML = `<div class="timeline-track litl"><span class="tl-stage done">Hypothesis</span><span class="tl-stage active">Generate</span><span class="tl-stage">DFT</span><span class="tl-stage">Assay</span></div>`;
    } else {
      el.innerHTML = `<div class="timeline-track"><span class="tl-shot muted">Bench run · tier-2</span></div>`;
    }
  }

  global.StudioPanels = {
    initPanels,
    switchBottom,
    renderInspector,
    renderProblems,
    appendTerminal,
    showTimelineForDemo,
    insertComposerChip,
  };
})(window);

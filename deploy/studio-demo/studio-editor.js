/* Code editor wireframe — CodeMirror + tabs + inline diff (native: li-studio-editor). */
(function (global) {
  let cm = null;
  let activePath = "world.li";
  const openTabs = new Set(["world.li"]);

  function getTheme() {
    const t = document.documentElement.dataset.theme || "aurora";
    if (t === "ember") return "ambiance";
    if (t === "slate") return "eclipse";
    return "dracula";
  }

  function initEditor() {
    const host = document.getElementById("code-editor-host");
    if (!host || !global.CodeMirror) return;

    const file = StudioFiles.FILES[activePath];
    cm = CodeMirror(host, {
      value: file?.sample || "",
      mode: file?.language === "toml" ? "properties" : "python",
      theme: getTheme(),
      lineNumbers: true,
      lineWrapping: false,
      tabSize: 4,
      indentUnit: 4,
      extraKeys: {
        "Cmd-S": () => global.runCommand?.(3),
        "Ctrl-S": () => global.runCommand?.(3),
        "Cmd-B": () => global.runCommand?.(3),
        "Ctrl-B": () => global.runCommand?.(3),
      },
    });
    cm.on("change", () => {
      if (StudioFiles.FILES[activePath]) StudioFiles.FILES[activePath].dirty = true;
      renderFileTabs();
    });
    renderFileTabs();
  }

  function renderFileTabs() {
    const bar = document.getElementById("editor-file-tabs");
    if (!bar) return;
    bar.innerHTML = "";
    openTabs.forEach((path) => {
      const f = StudioFiles.FILES[path];
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = `editor-tab${path === activePath ? " active" : ""}`;
      btn.dataset.path = path;
      const dirty = f?.dirty ? " •" : "";
      btn.textContent = `${path.split("/").pop()}${dirty}`;
      btn.title = path;
      btn.addEventListener("click", () => openFile(path));
      bar.appendChild(btn);
    });
    const add = document.createElement("button");
    add.type = "button";
    add.className = "editor-tab editor-tab--add";
    add.textContent = "+";
    add.title = "New .li file";
    add.addEventListener("click", () => {
      const name = `custom_${Date.now()}.li`;
      const path = `packages/game/${name}`;
      StudioFiles.FILES[path] = {
        path,
        language: "python",
        dirty: true,
        sample: "def on_create() -> unit:\n    pass\n",
      };
      openTabs.add(path);
      openFile(path);
    });
    bar.appendChild(add);
  }

  function openFile(path, line) {
    if (!StudioFiles.FILES[path]) return;
    if (cm && activePath && StudioFiles.FILES[activePath]) {
      StudioFiles.FILES[activePath].sample = cm.getValue();
    }
    activePath = path;
    openTabs.add(path);
    if (cm) {
      const f = StudioFiles.FILES[path];
      cm.setValue(f.sample);
      cm.setOption("mode", f.language === "toml" ? "properties" : "python");
      if (line != null) {
        cm.setCursor(line - 1, 0);
        cm.scrollIntoView({ line: line - 1, ch: 0 }, 80);
      }
    }
    renderFileTabs();
    switchCenterPanel("editor");
    document.querySelectorAll(".outliner li").forEach((li) => {
      li.classList.toggle("active", li.dataset.entity === path || li.textContent === path.split("/").pop());
    });
  }

  function switchCenterPanel(id) {
    document.querySelectorAll("[data-center-panel]").forEach((el) => {
      const on = el.dataset.centerPanel === id;
      el.classList.toggle("hidden", !on);
      el.hidden = !on;
    });
    document.querySelectorAll(".center-tab").forEach((b) => {
      b.classList.toggle("active", b.dataset.center === id);
    });
  }

  function showDiff(path) {
    const panel = document.getElementById("diff-panel");
    const body = document.getElementById("diff-body");
    const patch = StudioFiles.PATCH_DIFF[path];
    if (!panel || !body || !patch) return;
    panel.classList.remove("hidden");
    body.innerHTML = patch.hunks
      .map((h) => {
        const cls = h.type === "add" ? "diff-add" : h.type === "del" ? "diff-del" : "diff-ctx";
        return `<div class="diff-line ${cls}">${escapeHtml(h.text)}</div>`;
      })
      .join("");
    switchCenterPanel("editor");
    openFile(path);
  }

  function hideDiff() {
    document.getElementById("diff-panel")?.classList.add("hidden");
  }

  function applyPatch() {
    const patch = StudioFiles.PATCH_DIFF[activePath];
    if (!patch || !cm) return;
    hideDiff();
    const cur = StudioFiles.FILES[activePath];
    cur.sample = cur.sample.replace("at=(0.0, 0.0, 0.0)", "at=(0.0, 12.0, 0.0)");
    cm.setValue(cur.sample);
    cur.dirty = true;
    renderFileTabs();
  }

  function refreshTheme() {
    if (cm) cm.setOption("theme", getTheme());
  }

  function escapeHtml(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;");
  }

  global.StudioEditor = {
    initEditor,
    openFile,
    switchCenterPanel,
    showDiff,
    hideDiff,
    applyPatch,
    refreshTheme,
    getActivePath: () => activePath,
  };
})(window);

/* Theme registry: built-ins (CSS) + user custom overrides (JSON / localStorage). */
(function (global) {
  const STORAGE_THEME = "li-studio-theme";
  const STORAGE_CUSTOM = "li-studio-custom-theme";
  const BUILTIN = ["aurora", "ember", "slate"];

  /** Maps JSON keys → CSS custom property names. */
  const TOKEN_KEYS = [
    "bg-deep",
    "bg-surface",
    "bg-elevated",
    "bg-input",
    "bg-viewport",
    "text",
    "text-secondary",
    "muted",
    "accent",
    "agent",
    "pass",
    "warn",
    "fail",
    "border-focus",
    "user-bubble",
    "canvas-bg",
    "canvas-accent",
    "canvas-pass",
    "canvas-violet",
    "canvas-coral",
    "canvas-muted",
    "canvas-elevated",
    "canvas-border",
    "canvas-surface2",
    "canvas-text",
    "canvas-terrain",
  ];

  function tokensToCss(tokens) {
    return TOKEN_KEYS.filter((k) => tokens[k])
      .map((k) => `--${k}: ${tokens[k]};`)
      .join("\n  ");
  }

  function injectCustomStyle(cssBlock) {
    let el = document.getElementById("studio-theme-custom");
    if (!el) {
      el = document.createElement("style");
      el.id = "studio-theme-custom";
      document.head.appendChild(el);
    }
    el.textContent = cssBlock;
  }

  function clearCustomStyle() {
    const el = document.getElementById("studio-theme-custom");
    if (el) el.textContent = "";
  }

  function loadCustomFromStorage() {
    try {
      const raw = localStorage.getItem(STORAGE_CUSTOM);
      if (!raw) return null;
      const parsed = JSON.parse(raw);
      if (!parsed || typeof parsed.tokens !== "object") return null;
      return parsed;
    } catch (_) {
      return null;
    }
  }

  function saveCustomTheme(theme) {
    localStorage.setItem(STORAGE_CUSTOM, JSON.stringify(theme));
    localStorage.setItem(STORAGE_THEME, "custom");
  }

  function applyCustomTheme(theme) {
    const tokens = theme.tokens || {};
    const derived = { ...tokens };
    if (tokens.pass && !tokens["canvas-pass"]) derived["canvas-pass"] = tokens.pass;
    if (tokens.accent && !tokens["canvas-accent"]) derived["canvas-accent"] = tokens.accent;
    if (tokens["bg-viewport"] && !tokens["canvas-bg"]) derived["canvas-bg"] = tokens["bg-viewport"];
    if (tokens.muted && !tokens["canvas-muted"]) derived["canvas-muted"] = tokens.muted;
    if (tokens["bg-elevated"] && !tokens["canvas-elevated"]) derived["canvas-elevated"] = tokens["bg-elevated"];
    injectCustomStyle(`:root[data-theme="custom"] {\n  ${tokensToCss(derived)}\n}`);
    document.documentElement.dataset.theme = "custom";
    updateThemeUi("custom", theme.name || "Custom");
    if (typeof global.syncCanvasColors === "function") global.syncCanvasColors();
  }

  function applyBuiltinTheme(id) {
    clearCustomStyle();
    document.documentElement.dataset.theme = id;
    localStorage.setItem(STORAGE_THEME, id);
    updateThemeUi(id, id.charAt(0).toUpperCase() + id.slice(1));
    if (typeof global.syncCanvasColors === "function") global.syncCanvasColors();
  }

  function updateThemeUi(activeId, customLabel) {
    document.querySelectorAll(".theme-btn[data-theme]").forEach((b) => {
      const isBuiltin = b.dataset.theme === activeId;
      const isCustom = activeId === "custom" && b.dataset.theme === "custom";
      const on = isBuiltin || isCustom;
      b.classList.toggle("active", on);
      b.setAttribute("aria-pressed", on ? "true" : "false");
    });
    const label = document.getElementById("theme-custom-label");
    if (label && activeId === "custom") label.textContent = customLabel;
  }

  function applyTheme(id, customPayload) {
    if (id === "custom") {
      const theme = customPayload || loadCustomFromStorage();
      if (theme) applyCustomTheme(theme);
      return;
    }
    if (!BUILTIN.includes(id)) return;
    applyBuiltinTheme(id);
  }

  function exportCustomTheme() {
    const theme = loadCustomFromStorage();
    if (!theme) return null;
    return JSON.stringify(theme, null, 2);
  }

  function parseThemeJson(text) {
    const data = JSON.parse(text);
    if (!data.tokens || typeof data.tokens !== "object") {
      throw new Error("Theme JSON must include a tokens object");
    }
    return data;
  }

  global.StudioThemes = {
    BUILTIN,
    TOKEN_KEYS,
    applyTheme,
    applyBuiltinTheme,
    applyCustomTheme,
    loadCustomFromStorage,
    saveCustomTheme,
    exportCustomTheme,
    parseThemeJson,
    clearCustomStyle,
  };
})(window);

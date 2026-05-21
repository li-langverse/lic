#!/usr/bin/env node
/**
 * Capture Studio UI screenshots from the HTML prototype (not stored in git).
 * Output: .artifacts/studio-mockups/<demo>.png + preview.html
 *
 * Usage: node scripts/capture-studio-mockup-screenshots.mjs
 * Requires: CHROME or google-chrome, puppeteer-core (studio-demo-pkg)
 */
import { spawn } from "node:child_process";
import { createRequire } from "node:module";
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const DEMO = path.join(ROOT, "deploy/studio-demo");
const OUT = path.join(ROOT, ".artifacts/studio-mockups");

/** Workspaces to capture (matches studio.js tabs). */
const SHOTS = [
  { id: "rocket", label: "Game · viewport + agent dock" },
  { id: "scientific", label: "Scientific · field + validity" },
  { id: "agent", label: "Agent · diagnose workspace" },
  { id: "publish", label: "Publish · bundle hash" },
  { id: "drug", label: "Drug LITL" },
  { id: "mmo", label: "MMO · shards" },
];

async function main() {
  const puppeteer = require(
    path.join(ROOT, "scripts/studio-demo-pkg/node_modules/puppeteer-core")
  );
  await mkdir(OUT, { recursive: true });

  const chrome = process.env.CHROME || "/usr/local/bin/google-chrome";
  const browser = await puppeteer.launch({
    executablePath: chrome,
    headless: true,
    args: ["--no-sandbox", "--window-size=1400,900"],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1400, height: 900, deviceScaleFactor: 2 });

  const files = [];
  for (const { id, label } of SHOTS) {
    const url = `file://${DEMO}/index.html?demo=${id}`;
    await page.goto(url, { waitUntil: "networkidle0" });
    await page.waitForSelector("#agent-chat", { timeout: 10000 });
    await new Promise((r) => setTimeout(r, 600));
    const outPath = path.join(OUT, `${id}.png`);
    await page.screenshot({ path: outPath, fullPage: false });
    files.push({ id, label, file: `${id}.png` });
    console.log(`  ${outPath}`);
  }
  await browser.close();

  const previewHtml = buildPreview(files, OUT);
  const previewPath = path.join(OUT, "preview.html");
  await writeFile(previewPath, previewHtml, "utf-8");
  console.log(`\nOpen: file://${previewPath}`);
  console.log(`Or:   ./scripts/open-studio-design-preview.sh --gallery`);
}

function buildPreview(files, outDir) {
  const figures = files
    .map(
      (f) => `
      <figure>
        <img src="${f.file}" alt="${f.label}" loading="lazy" />
        <figcaption><strong>${f.id}</strong> — ${f.label}</figcaption>
      </figure>`
    )
    .join("");
  return `<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"/><title>Studio mockups (local)</title>
<style>
  body{font-family:system-ui;background:#0f1219;color:#e8ecf4;padding:1.5rem;margin:0}
  h1{font-size:1.25rem} p{color:#8b95a8}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(400px,1fr));gap:1rem}
  figure{margin:0;background:#161b26;border:1px solid #2a3348;border-radius:8px;overflow:hidden}
  img{width:100%;display:block} figcaption{padding:.5rem .75rem;font-size:.8rem;color:#8b95a8}
  a{color:#2dd4bf}
</style></head><body>
<h1>Li World Studio — local screenshots</h1>
<p>Generated from <code>deploy/studio-demo/index.html</code>. Not in git — regenerate with
<code>./scripts/capture-studio-mockup-screenshots.sh</code>.</p>
<p><a href="../../deploy/studio-demo/index.html">Interactive demo</a></p>
<div class="grid">${figures}</div>
</body></html>`;
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

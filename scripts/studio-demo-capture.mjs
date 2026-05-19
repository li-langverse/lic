#!/usr/bin/env node
/**
 * Fast studio demo capture — single headless Chrome session.
 * Usage: node scripts/studio-demo-capture.mjs [seconds] [fps]
 */
import { spawn } from "node:child_process";
import { createRequire } from "node:module";
import { mkdir, rm, readdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(__dirname, "..");
const DEMO = path.join(ROOT, "deploy/studio-demo");
const OUT = path.join(DEMO, "videos");
const FRAMES = path.join(OUT, "frames");
const DURATION = Number(process.argv[2] || 24);
const FPS = Number(process.argv[3] || 12);
const URL = `file://${DEMO}/index.html?autoreel=1`;

async function main() {
  const puppeteer = require(
    path.join(ROOT, "scripts/studio-demo-pkg/node_modules/puppeteer-core")
  );
  await rm(FRAMES, { recursive: true, force: true });
  await mkdir(FRAMES, { recursive: true });
  await mkdir(OUT, { recursive: true });

  const chrome = process.env.CHROME || "/usr/local/bin/google-chrome";
  const browser = await puppeteer.launch({
    executablePath: chrome,
    headless: true,
    args: ["--no-sandbox", "--window-size=1280,720"],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 720 });
  await page.goto(URL, { waitUntil: "networkidle0" });

  const total = DURATION * FPS;
  for (let i = 0; i < total; i++) {
    await page.screenshot({
      path: path.join(FRAMES, `frame_${String(i).padStart(5, "0")}.png`),
    });
    await new Promise((r) => setTimeout(r, 1000 / FPS));
  }
  await browser.close();

  const webm = path.join(OUT, "world-studio-demo-reel.webm");
  await run("ffmpeg", [
    "-y", "-framerate", String(FPS), "-i", path.join(FRAMES, "frame_%05d.png"),
    "-c:v", "libvpx-vp9", "-pix_fmt", "yuv420p", "-crf", "34", webm,
  ]).catch(() =>
    run("ffmpeg", [
      "-y", "-framerate", String(FPS), "-i", path.join(FRAMES, "frame_%05d.png"),
      "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "23",
      path.join(OUT, "world-studio-demo-reel.mp4"),
    ])
  );
  const n = (await readdir(FRAMES)).length;
  console.log(`Captured ${n} frames → ${OUT}/world-studio-demo-reel.*`);
}

function run(cmd, args) {
  return new Promise((resolve, reject) => {
    const p = spawn(cmd, args, { stdio: "inherit" });
    p.on("close", (c) => (c === 0 ? resolve() : reject(new Error(cmd))));
  });
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

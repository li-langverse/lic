#!/usr/bin/env node
/**
 * Lightweight Next.js-style toy backend for tier5_http proxy benches.
 * Routes mirror common App Router patterns (API / SSR / SSE / WS) without `next build`.
 *
 * Usage: node server.mjs <port>
 */
import http from "node:http";
import { createHash } from "node:crypto";

const port = Number(process.argv[2] || "19001");
if (!Number.isInteger(port) || port < 1024 || port > 65000) {
  console.error("nextjs-toy: need valid port 1024-65000");
  process.exit(2);
}

const SSR_HTML = `<!DOCTYPE html><html><head><title>toy-ssr</title></head>
<body><main id="__next" data-ssr="1"><h1>toy-ssr</h1><p>rendered=${Date.now()}</p></main></body></html>`;

function sendJson(res, code, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(code, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(body),
    "X-Powered-By": "nextjs-toy",
  });
  res.end(body);
}

function handleSse(res) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream; charset=utf-8",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
    "X-Powered-By": "nextjs-toy",
  });
  res.write("event: open\ndata: {}\n\n");
  res.write('event: tick\ndata: {"n":1}\n\n');
  res.end();
}

function acceptWebSocket(req, socket) {
  const key = req.headers["sec-websocket-key"];
  if (!key) {
    socket.destroy();
    return;
  }
  const accept = createHash("sha1")
    .update(key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
    .digest("base64");
  socket.write(
    "HTTP/1.1 101 Switching Protocols\r\n" +
      "Upgrade: websocket\r\n" +
      "Connection: Upgrade\r\n" +
      `Sec-WebSocket-Accept: ${accept}\r\n` +
      "X-Powered-By: nextjs-toy\r\n" +
      "\r\n"
  );
  // Minimal server→client text frame ("ok") for verify harness.
  const payload = Buffer.from("ok");
  const frame = Buffer.alloc(2 + payload.length);
  frame[0] = 0x81;
  frame[1] = payload.length;
  payload.copy(frame, 2);
  socket.write(frame);
  socket.end();
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url || "/", `http://127.0.0.1:${port}`);
  const path = url.pathname;

  if (path === "/api/hello" && req.method === "GET") {
    return sendJson(res, 200, { ok: true, route: "api", ts: Date.now() });
  }
  if (path === "/ssr/page" && req.method === "GET") {
    res.writeHead(200, {
      "Content-Type": "text/html; charset=utf-8",
      "Content-Length": Buffer.byteLength(SSR_HTML),
      "X-Powered-By": "nextjs-toy",
    });
    return res.end(SSR_HTML);
  }
  if (path === "/api/sse" && req.method === "GET") {
    return handleSse(res);
  }
  if (path === "/api/ws") {
    res.writeHead(426, { "Content-Type": "text/plain" });
    return res.end("upgrade required\n");
  }
  res.writeHead(404, { "Content-Type": "text/plain" });
  res.end("not found\n");
});

server.on("upgrade", (req, socket) => {
  const path = (req.url || "").split("?")[0];
  if (path === "/api/ws") {
    return acceptWebSocket(req, socket);
  }
  socket.destroy();
});

server.listen(port, "127.0.0.1", () => {
  process.stdout.write(`nextjs-toy listening on 127.0.0.1:${port}\n`);
});

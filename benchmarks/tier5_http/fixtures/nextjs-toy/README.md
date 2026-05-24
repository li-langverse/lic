# nextjs-toy — tier5_http backend

Minimal Node server emulating common **Next.js App Router** surfaces for proxy parity benches:

| Route | Pattern | Used by scenario |
|-------|---------|------------------|
| `GET /api/hello` | JSON API | `nextjs_api` |
| `GET /ssr/page` | HTML SSR shell | `nextjs_ssr` |
| `GET /api/sse` | `text/event-stream` | `nextjs_sse` |
| `WS /api/ws` | WebSocket upgrade | `nextjs_ws` |

No `npm install` — run with system `node`:

```bash
node benchmarks/tier5_http/fixtures/nextjs-toy/server.mjs 19001
```

Harness starts this process automatically for `server.kind = "proxy"` + `backend = "nextjs_toy"`.

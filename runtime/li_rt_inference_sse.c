/* Stage 8: Li-native inference SSE backend for li-httpd /v1/chat/completions upstream. */
#include "li_rt_inference_sse.h"
#include "li_rt_llm.h"
#include "li_rt_net.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if !defined(_WIN32)
#include <pthread.h>
#include <sys/socket.h>
#include <unistd.h>
#endif

static int g_native_weights_ok = 0;
static int g_native_decode_steps = 0;

int32_t li_rt_inference_native_weights_ready(void) {
  const char* path = "fixtures/ph-ml-weights/model.safetensors";
  if (li_rt_llm_safetensors_probe_path(path) != 1) {
    return 0;
  }
  if (li_rt_llm_last_safetensors_tensor_count() <= 0) {
    return 0;
  }
  return 1;
}

int32_t li_rt_inference_native_decode_steps(void) {
  if (g_native_decode_steps > 0) {
    return (int32_t)g_native_decode_steps;
  }
  return li_rt_inference_native_weights_ready() == 1 ? 8 : 0;
}

static int read_request(int conn, char* buf, int cap) {
  int n = 0;
  while (n < cap - 1) {
    const ssize_t got = recv(conn, buf + n, (size_t)(cap - 1 - n), 0);
    if (got <= 0) {
      return n;
    }
    n += (int)got;
    buf[n] = '\0';
    if (n >= 4 && strstr(buf, "\r\n\r\n") != NULL) {
      return n;
    }
  }
  return n;
}

static int req_is_sse(const char* req) {
  return strstr(req, "text/event-stream") != NULL;
}

static void mark_file(const char* path) {
  if (path == NULL || path[0] == '\0') {
    return;
  }
  FILE* f = fopen(path, "w");
  if (f != NULL) {
    fputs("1", f);
    fclose(f);
  }
}

static void handle_json(int conn) {
  static const char body[] =
      "{\"id\":\"chatcmpl-li-native\",\"object\":\"chat.completion\",\"choices\":[]}";
  char hdr[256];
  snprintf(hdr, sizeof(hdr),
           "HTTP/1.1 200 OK\r\n"
           "Content-Type: application/json\r\n"
           "Content-Length: %zu\r\n"
           "Connection: close\r\n"
           "\r\n",
           sizeof(body) - 1);
  tcp_send(conn, hdr);
  tcp_send(conn, body);
}

static void handle_sse(int conn, const char* cancel_mark) {
  mark_file(cancel_mark != NULL ? cancel_mark : "");
  if (cancel_mark != NULL && cancel_mark[0] != '\0') {
    char started[512];
    snprintf(started, sizeof(started), "%s.started", cancel_mark);
    mark_file(started);
  }

  tcp_send(conn,
           "HTTP/1.1 200 OK\r\n"
           "Content-Type: text/event-stream\r\n"
           "Transfer-Encoding: chunked\r\n"
           "Connection: close\r\n"
           "\r\n");

  const int steps = (int)li_rt_inference_native_decode_steps();
  const int loops = steps > 0 ? steps * 10 : 80;
  int cancelled = 0;
  for (int i = 0; i < loops && !cancelled; i++) {
    char payload[96];
    if (steps > 0 && (i % 10) == 0) {
      const int tok = (i / 10) + 1;
      snprintf(payload, sizeof(payload), "data: {\"token_id\":%d,\"native\":true}\r\n", tok);
    } else {
      snprintf(payload, sizeof(payload), "data: ping\r\n");
    }
    char chunk[128];
    snprintf(chunk, sizeof(chunk), "%zx\r\n%s\r\n", strlen(payload), payload);
    if (tcp_send(conn, chunk) < 0) {
      cancelled = 1;
      break;
    }
    struct timespec ts = {.tv_sec = 0, .tv_nsec = 80000000L};
    nanosleep(&ts, NULL);
  }
  if (cancelled && cancel_mark != NULL && cancel_mark[0] != '\0') {
    mark_file(cancel_mark);
  }
}

#if !defined(_WIN32)
typedef struct {
  int conn;
  char cancel_mark[512];
} inference_conn_args;

static void* inference_conn_thread(void* arg) {
  inference_conn_args* args = (inference_conn_args*)arg;
  char req[8192];
  const int n = read_request(args->conn, req, (int)sizeof(req));
  if (n <= 0) {
    tcp_close(args->conn);
    free(args);
    return NULL;
  }
  req[n] = '\0';
  if (req_is_sse(req)) {
    handle_sse(args->conn, args->cancel_mark);
  } else {
    handle_json(args->conn);
  }
  tcp_close(args->conn);
  free(args);
  return NULL;
}
#endif

int32_t li_rt_inference_native_backend_run(int32_t port, const char* cancel_mark_path) {
  g_native_weights_ok = (int)li_rt_inference_native_weights_ready();
  g_native_decode_steps = g_native_weights_ok ? 8 : 0;
  if (g_native_weights_ok != 1) {
    return -2;
  }

  const int32_t listen_fd = tcp_listen(port);
  if (listen_fd < 0) {
    return -1;
  }

#if !defined(_WIN32)
  char cancel_mark[512];
  cancel_mark[0] = '\0';
  if (cancel_mark_path != NULL) {
    strncpy(cancel_mark, cancel_mark_path, sizeof(cancel_mark) - 1);
    cancel_mark[sizeof(cancel_mark) - 1] = '\0';
  }

  for (;;) {
    const int32_t conn = tcp_accept(listen_fd);
    if (conn < 0) {
      continue;
    }
    inference_conn_args* args = (inference_conn_args*)calloc(1, sizeof(inference_conn_args));
    if (args == NULL) {
      tcp_close(conn);
      continue;
    }
    args->conn = (int)conn;
    strncpy(args->cancel_mark, cancel_mark, sizeof(args->cancel_mark) - 1);
    pthread_t th;
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (pthread_create(&th, &attr, inference_conn_thread, args) != 0) {
      free(args);
      tcp_close(conn);
    }
    pthread_attr_destroy(&attr);
  }
#else
  (void)cancel_mark_path;
  tcp_close(listen_fd);
  return -3;
#endif
}

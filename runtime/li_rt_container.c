#if !defined(_WIN32)
#define _GNU_SOURCE
#endif
#if defined(__linux__)
#include <unistd.h>
#include <sys/mount.h>
#include <sys/syscall.h>
#if !defined(pivot_root)
int pivot_root(const char* new_root, const char* put_old);
#endif
#if __has_include(<sys/seccomp.h>)
#include <sys/seccomp.h>
#else
#include <linux/seccomp.h>
static inline int li_rt_seccomp(unsigned int operation, unsigned int flags, void* args) {
  return (int)syscall(__NR_seccomp, operation, flags, args);
}
#define seccomp li_rt_seccomp
#endif
#endif
#include "li_rt.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32)
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#endif

#if defined(__linux__)
#include <sched.h>
#include <sys/prctl.h>
#include <linux/bpf.h>
#include <linux/filter.h>
#include <linux/seccomp.h>
#include <linux/unistd.h>
#endif

#define CONTAINER_RT_TAG 1

#if defined(__linux__)
#ifndef CLONE_NEWPID
#define CLONE_NEWPID 0x20000000
#endif
#ifndef CLONE_NEWNS
#define CLONE_NEWNS 0x00020000
#endif
#ifndef CLONE_NEWNET
#define CLONE_NEWNET 0x40000000
#endif
#ifndef CLONE_NEWUTS
#define CLONE_NEWUTS 0x04000000
#endif
#ifndef CLONE_NEWIPC
#define CLONE_NEWIPC 0x08000000
#endif
#ifndef CLONE_NEWUSER
#define CLONE_NEWUSER 0x10000000
#endif
#ifndef CLONE_NEWCGROUP
#define CLONE_NEWCGROUP 0x02000000
#endif
#endif

static int container_dry_run(void) {
  const char* env = getenv("LI_CONTAINER_DRY_RUN");
  return (env != NULL && env[0] == '1') ? 1 : 0;
}

static int container_copy_cstr(char* out, int cap, const char* src) {
  if (out == NULL || cap <= 0) {
    return -1;
  }
  if (src == NULL) {
    out[0] = '\0';
    return 0;
  }
  int n = (int)strlen(src);
  if (n >= cap) {
    n = cap - 1;
  }
  memcpy(out, src, (size_t)n);
  out[n] = '\0';
  return n;
}

static const char* container_state_root(void) {
  const char* env = getenv("LI_CONTAINER_STATE_DIR");
  return (env != NULL && env[0] != '\0') ? env : "/run/li-container";
}

int container_runtime_tag_i(void) { return CONTAINER_RT_TAG; }

static int container_env_os_value_is(const char* name, const char* value) {
  const char* env = getenv(name);
  return (env != NULL && value != NULL && strcmp(env, value) == 0) ? 1 : 0;
}

int container_is_linux_i(void) {
#if defined(__linux__)
  if (container_env_os_value_is("LI_CONTAINER_OS", "lios")) {
    return 0;
  }
  if (container_env_os_value_is("LIBERNETES_OS", "lios")) {
    return 0;
  }
  return 1;
#else
  return 0;
#endif
}

int container_is_lios_i(void) {
  if (container_env_os_value_is("LI_CONTAINER_OS", "lios")) {
    return 1;
  }
  if (container_env_os_value_is("LIBERNETES_OS", "lios")) {
    return 1;
  }
  return 0;
}

int container_is_windows_i(void) {
#if defined(_WIN32)
  return 1;
#else
  if (container_env_os_value_is("LI_CONTAINER_OS", "windows")) {
    return 1;
  }
  if (container_env_os_value_is("LIBERNETES_OS", "windows")) {
    return 1;
  }
  return 0;
#endif
}

int container_is_darwin_i(void) {
#if defined(__APPLE__)
  return 1;
#else
  if (container_env_os_value_is("LI_CONTAINER_OS", "darwin")) {
    return 1;
  }
  if (container_env_os_value_is("LIBERNETES_OS", "darwin")) {
    return 1;
  }
  return 0;
#endif
}

int container_mkdir_p_i(char* path) {
#if defined(_WIN32)
  (void)path;
  return -1;
#else
  if (path == NULL || path[0] == '\0') {
    return -1;
  }
  char buf[4096];
  container_copy_cstr(buf, (int)sizeof(buf), path);
  size_t len = strlen(buf);
  for (size_t i = 1; i < len; ++i) {
    if (buf[i] == '/') {
      buf[i] = '\0';
      if (mkdir(buf, 0755) != 0 && errno != EEXIST) {
        return -1;
      }
      buf[i] = '/';
    }
  }
  if (mkdir(buf, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  return 0;
#endif
}

int container_file_exists_i(char* path) {
#if defined(_WIN32)
  (void)path;
  return 0;
#else
  if (path == NULL) {
    return 0;
  }
  return access(path, F_OK) == 0 ? 1 : 0;
#endif
}

int container_read_file_i(char* path, char* buf, int cap) {
#if defined(_WIN32)
  (void)path;
  (void)buf;
  (void)cap;
  return -1;
#else
  if (path == NULL || buf == NULL || cap <= 0) {
    return -1;
  }
  FILE* f = fopen(path, "rb");
  if (f == NULL) {
    return -1;
  }
  int n = (int)fread(buf, 1, (size_t)(cap - 1), f);
  fclose(f);
  if (n < 0) {
    return -1;
  }
  buf[n] = '\0';
  return n;
#endif
}

int container_write_file_i(char* path, char* data) {
#if defined(_WIN32)
  (void)path;
  (void)data;
  return -1;
#else
  if (path == NULL || data == NULL) {
    return -1;
  }
  FILE* f = fopen(path, "wb");
  if (f == NULL) {
    return -1;
  }
  size_t n = fwrite(data, 1, strlen(data), f);
  fclose(f);
  return (int)n;
#endif
}

int container_remove_file_i(char* path) {
#if defined(_WIN32)
  (void)path;
  return -1;
#else
  return (path != NULL && unlink(path) == 0) ? 0 : -1;
#endif
}

int container_remove_dir_i(char* path) {
#if defined(_WIN32)
  (void)path;
  return -1;
#else
  return (path != NULL && rmdir(path) == 0) ? 0 : -1;
#endif
}

int container_getenv_i(char* name, char* buf, int cap) {
  if (name == NULL || buf == NULL || cap <= 0) {
    return -1;
  }
  const char* v = getenv(name);
  if (v == NULL) {
    buf[0] = '\0';
    return 0;
  }
  return container_copy_cstr(buf, cap, v);
}

int container_env_is_i(char* name, char* value) {
  if (name == NULL || value == NULL) {
    return 0;
  }
  const char* v = getenv(name);
  return (v != NULL && strcmp(v, value) == 0) ? 1 : 0;
}

static int container_json_has_token(const char* json, const char* token) {
  return (json != NULL && token != NULL && strstr(json, token) != NULL) ? 1 : 0;
}

static int container_cgroup_write_i(const char* dir, const char* file, const char* value) {
  if (dir == NULL || file == NULL || value == NULL) {
    return -1;
  }
  char path[1024];
  snprintf(path, sizeof(path), "%s/%s", dir, file);
  return container_write_file_i(path, (char*)value);
}

static int container_cgroup_read_int_after_key(const char* json, const char* section, const char* key,
                                               long long* out) {
  if (json == NULL || section == NULL || key == NULL || out == NULL) {
    return -1;
  }
  const char* sec = strstr(json, section);
  if (sec == NULL) {
    return -1;
  }
  char pattern[128];
  snprintf(pattern, sizeof(pattern), "\"%s\"", key);
  const char* hit = strstr(sec, pattern);
  if (hit == NULL) {
    return -1;
  }
  const char* colon = strchr(hit + strlen(pattern), ':');
  if (colon == NULL) {
    return -1;
  }
  const char* p = colon + 1;
  while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r') {
    ++p;
  }
  char* end = NULL;
  long long v = strtoll(p, &end, 10);
  if (end == p) {
    return -1;
  }
  *out = v;
  return 0;
}

static const char* container_json_find_value(const char* json, const char* key) {
  if (json == NULL || key == NULL) {
    return NULL;
  }
  char pattern[128];
  snprintf(pattern, sizeof(pattern), "\"%s\"", key);
  const char* hit = strstr(json, pattern);
  if (hit == NULL) {
    return NULL;
  }
  const char* colon = strchr(hit + strlen(pattern), ':');
  if (colon == NULL) {
    return NULL;
  }
  const char* p = colon + 1;
  while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r') {
    ++p;
  }
  return p;
}

int container_json_field_str_i(char* json, char* key, char* out, int cap) {
  const char* p = container_json_find_value(json, key);
  if (p == NULL || *p != '"') {
    return -1;
  }
  ++p;
  const char* end = strchr(p, '"');
  if (end == NULL) {
    return -1;
  }
  int n = (int)(end - p);
  if (n >= cap) {
    n = cap - 1;
  }
  memcpy(out, p, (size_t)n);
  out[n] = '\0';
  return n;
}

int container_json_field_int_i(char* json, char* key, char* out) {
  const char* p = container_json_find_value(json, key);
  if (p == NULL || out == NULL) {
    return -1;
  }
  char tmp[64];
  int i = 0;
  if (*p == '-') {
    tmp[i++] = *p++;
  }
  while (*p >= '0' && *p <= '9' && i < (int)sizeof(tmp) - 1) {
    tmp[i++] = *p++;
  }
  tmp[i] = '\0';
  return container_copy_cstr(out, 64, tmp);
}

int container_json_field_bool_i(char* json, char* key, char* out) {
  const char* p = container_json_find_value(json, key);
  if (p == NULL || out == NULL) {
    return -1;
  }
  if (strncmp(p, "true", 4) == 0) {
    return container_copy_cstr(out, 64, "true");
  }
  if (strncmp(p, "false", 5) == 0) {
    return container_copy_cstr(out, 64, "false");
  }
  return -1;
}

int container_state_dir_i(char* out, int cap) {
  return container_copy_cstr(out, cap, container_state_root());
}

int container_state_path_i(char* id, char* out, int cap) {
  if (id == NULL || out == NULL || cap <= 0) {
    return -1;
  }
  char dir[512];
  container_state_dir_i(dir, (int)sizeof(dir));
  snprintf(out, (size_t)cap, "%s/%s/state.json", dir, id);
  return (int)strlen(out);
}

int container_state_write_i(char* id, char* oci_version, char* status, int pid, int has_pid,
                          char* bundle, int exit_code, int has_exit) {
  (void)exit_code;
  (void)has_exit;
  char path[1024];
  char dir[512];
  container_state_dir_i(dir, (int)sizeof(dir));
  snprintf(path, sizeof(path), "%s/%s", dir, id);
  container_mkdir_p_i(path);
  container_state_path_i(id, path, (int)sizeof(path));
  char json[4096];
  if (has_pid) {
    snprintf(json, sizeof(json),
             "{\"ociVersion\":\"%s\",\"id\":\"%s\",\"status\":\"%s\",\"bundle\":\"%s\",\"pid\":%d}",
             oci_version != NULL ? oci_version : "1.0.2", id, status != NULL ? status : "created",
             bundle != NULL ? bundle : "", pid);
  } else {
    snprintf(json, sizeof(json),
             "{\"ociVersion\":\"%s\",\"id\":\"%s\",\"status\":\"%s\",\"bundle\":\"%s\"}",
             oci_version != NULL ? oci_version : "1.0.2", id, status != NULL ? status : "created",
             bundle != NULL ? bundle : "");
  }
  return container_write_file_i(path, json);
}

int container_state_read_i(char* id, char* json_out, int cap) {
  char path[1024];
  container_state_path_i(id, path, (int)sizeof(path));
  return container_read_file_i(path, json_out, cap);
}

int container_state_delete_i(char* id) {
  char path[1024];
  container_state_path_i(id, path, (int)sizeof(path));
  return container_remove_file_i(path);
}

int container_state_list_stdout_i(void) {
#if !defined(_WIN32)
  char dir[512];
  container_state_dir_i(dir, (int)sizeof(dir));
  DIR* dp = opendir(dir);
  if (dp == NULL) {
    return -1;
  }
  struct dirent* ent;
  while ((ent = readdir(dp)) != NULL) {
    if (ent->d_name[0] == '.') {
      continue;
    }
    char state_path[1024];
    snprintf(state_path, sizeof(state_path), "%s/%s/state.json", dir, ent->d_name);
    if (container_file_exists_i(state_path) != 1) {
      continue;
    }
    fputs(ent->d_name, stdout);
    fputc('\n', stdout);
  }
  closedir(dp);
  return 0;
#else
  return -1;
#endif
}

int container_cgroup_root_i(char* out, int cap) {
  return container_copy_cstr(out, cap, "/sys/fs/cgroup");
}

int container_cgroup_path_i(char* id, char* out, int cap) {
  if (id == NULL || out == NULL || cap <= 0) {
    return -1;
  }
  char root[512];
  container_cgroup_root_i(root, (int)sizeof(root));
  snprintf(out, (size_t)cap, "%s/li-container/%s", root, id);
  return (int)strlen(out);
}

int container_cgroup_create_i(char* id) {
  if (id == NULL) {
    return -1;
  }
  char root[512];
  container_cgroup_root_i(root, (int)sizeof(root));
  char parent[1024];
  snprintf(parent, sizeof(parent), "%s/li-container", root);
  if (container_mkdir_p_i(parent) != 0) {
    return -1;
  }
  char path[1024];
  container_cgroup_path_i(id, path, (int)sizeof(path));
  if (container_mkdir_p_i(path) != 0) {
    return -1;
  }
#if defined(__linux__)
  if (!container_dry_run()) {
    (void)container_cgroup_write_i(root, "cgroup.subtree_control", "+memory +cpu +pids");
    (void)container_cgroup_write_i(parent, "cgroup.subtree_control", "+memory +cpu +pids");
  }
#endif
  return 0;
}

int container_cgroup_remove_i(char* id) {
  char path[1024];
  container_cgroup_path_i(id, path, (int)sizeof(path));
  return container_remove_dir_i(path);
}

int container_cgroup_join_i(char* id) {
#if defined(__linux__)
  if (id == NULL) {
    return -1;
  }
  if (container_dry_run()) {
    return 0;
  }
  char path[1024];
  container_cgroup_path_i(id, path, (int)sizeof(path));
  char pidbuf[32];
  snprintf(pidbuf, sizeof(pidbuf), "%d", (int)getpid());
  return container_cgroup_write_i(path, "cgroup.procs", pidbuf);
#else
  (void)id;
  return -1;
#endif
}

int container_cgroup_apply_limits_i(char* cgroup_path, char* config_json) {
  if (cgroup_path == NULL) {
    return -1;
  }
#if defined(__linux__)
  if (container_dry_run()) {
    return 0;
  }
  long long memory_limit = 0;
  if (container_cgroup_read_int_after_key(config_json, "\"memory\"", "limit", &memory_limit) == 0 &&
      memory_limit > 0) {
    char buf[64];
    snprintf(buf, sizeof(buf), "%lld", memory_limit);
    if (container_cgroup_write_i(cgroup_path, "memory.max", buf) != 0) {
      return -1;
    }
  }
  long long cpu_quota = 0;
  long long cpu_period = 0;
  int has_quota = container_cgroup_read_int_after_key(config_json, "\"cpu\"", "quota", &cpu_quota) == 0;
  int has_period = container_cgroup_read_int_after_key(config_json, "\"cpu\"", "period", &cpu_period) == 0;
  if (has_quota && has_period && cpu_period > 0) {
    char buf[64];
    snprintf(buf, sizeof(buf), "%lld %lld", cpu_quota, cpu_period);
    if (container_cgroup_write_i(cgroup_path, "cpu.max", buf) != 0) {
      return -1;
    }
  }
  return 0;
#else
  (void)config_json;
  return -1;
#endif
}

int container_namespace_flags_i(char* config_json) {
#if defined(__linux__)
  int flags = 0;
  if (config_json == NULL || config_json[0] == '\0') {
    return CLONE_NEWPID | CLONE_NEWNS;
  }
  if (container_json_has_token(config_json, "\"pid\"")) {
    flags |= CLONE_NEWPID;
  }
  if (container_json_has_token(config_json, "\"mount\"")) {
    flags |= CLONE_NEWNS;
  }
  if (container_json_has_token(config_json, "\"network\"")) {
    flags |= CLONE_NEWNET;
  }
  if (container_json_has_token(config_json, "\"uts\"")) {
    flags |= CLONE_NEWUTS;
  }
  if (container_json_has_token(config_json, "\"ipc\"")) {
    flags |= CLONE_NEWIPC;
  }
  if (container_json_has_token(config_json, "\"user\"")) {
    flags |= CLONE_NEWUSER;
  }
  if (container_json_has_token(config_json, "\"cgroup\"")) {
    flags |= CLONE_NEWCGROUP;
  }
  return flags != 0 ? flags : (CLONE_NEWPID | CLONE_NEWNS);
#else
  (void)config_json;
  return 0;
#endif
}

int container_json_process_uid_i(char* config_json) {
  char tmp[64];
  if (container_json_field_int_i(config_json, "uid", tmp) < 0) {
    return 0;
  }
  return atoi(tmp);
}

int container_json_process_gid_i(char* config_json) {
  char tmp[64];
  if (container_json_field_int_i(config_json, "gid", tmp) < 0) {
    return 0;
  }
  return atoi(tmp);
}

int container_state_pid_value_i(char* state_json) {
  char tmp[64];
  if (container_json_field_int_i(state_json, "pid", tmp) < 0) {
    return 0;
  }
  return atoi(tmp);
}

int container_stdout_i(char* msg) {
  if (msg == NULL) {
    return -1;
  }
  fputs(msg, stdout);
  fputc('\n', stdout);
  return 0;
}

int container_unshare_i(int flags) {
#if defined(__linux__)
  if (container_dry_run()) {
    return 0;
  }
  return unshare((int)flags) == 0 ? 0 : -1;
#else
  (void)flags;
  return -1;
#endif
}

int container_fork_child_i(void) {
#if defined(_WIN32)
  return -1;
#else
  pid_t pid = fork();
  if (pid < 0) {
    return -1;
  }
  return (int)pid;
#endif
}

int container_pivot_root_i(char* rootfs_path) {
#if defined(__linux__)
  if (rootfs_path == NULL || rootfs_path[0] == '\0') {
    return -1;
  }
  if (container_dry_run()) {
    return 0;
  }
  const char* put_old = ".li_pivot_old";
  char put_old_path[4096];
  snprintf(put_old_path, sizeof(put_old_path), "%s/%s", rootfs_path, put_old);
  if (chdir(rootfs_path) != 0) {
    return -1;
  }
  if (mount(".", ".", NULL, MS_BIND | MS_REC, NULL) != 0) {
    return -1;
  }
  if (mkdir(put_old, 0755) != 0 && errno != EEXIST) {
    return -1;
  }
  if (pivot_root(".", put_old) != 0) {
    return -1;
  }
  if (chdir("/") != 0) {
    return -1;
  }
  char detach_path[4096];
  snprintf(detach_path, sizeof(detach_path), "/%s", put_old);
  umount2(detach_path, MNT_DETACH);
  rmdir(detach_path);
  return 0;
#else
  (void)rootfs_path;
  return -1;
#endif
}

int container_setup_rootfs_i(char* bundle_path, char* config_json) {
  if (bundle_path == NULL) {
    return -1;
  }
  char rootfs[1024];
  snprintf(rootfs, sizeof(rootfs), "%s/rootfs", bundle_path);
  if (!container_file_exists_i(rootfs)) {
    return -1;
  }
  return container_pivot_root_i(rootfs);
}

int container_drop_privileges_i(int uid, int gid) {
#if defined(__linux__)
  if (container_dry_run()) {
    return 0;
  }
  if (gid >= 0 && setgid((gid_t)gid) != 0) {
    return -1;
  }
  if (uid >= 0 && setuid((uid_t)uid) != 0) {
    return -1;
  }
  return 0;
#else
  (void)uid;
  (void)gid;
  return -1;
#endif
}

int container_exec_i(char* cwd, char* config_json) {
  (void)cwd;
  (void)config_json;
  return -1;
}

int container_kill_i(int pid, int signal) {
#if defined(_WIN32)
  (void)pid;
  (void)signal;
  return -1;
#else
  return kill((pid_t)pid, signal) == 0 ? 0 : -1;
#endif
}

int container_pid_alive_i(int pid) {
#if defined(_WIN32)
  (void)pid;
  return 0;
#else
  return kill((pid_t)pid, 0) == 0 ? 1 : 0;
#endif
}

#if defined(__linux__)
static int container_seccomp_install_default(void) {
  struct sock_filter filter[] = {
      BPF_STMT(BPF_LD | BPF_W | BPF_ABS, offsetof(struct seccomp_data, nr)),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_read, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_write, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_close, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_fstat, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_mmap, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_mprotect, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_munmap, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_brk, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_rt_sigreturn, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_exit, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, __NR_exit_group, 0, 1),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_ALLOW),
      BPF_STMT(BPF_RET | BPF_K, SECCOMP_RET_KILL_PROCESS),
  };
  struct sock_fprog prog = {
      .len = (unsigned short)(sizeof(filter) / sizeof(filter[0])),
      .filter = filter,
  };
  if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0) != 0) {
    return -1;
  }
  return seccomp(SECCOMP_SET_MODE_FILTER, SECCOMP_FILTER_FLAG_TSYNC, &prog) == 0 ? 0 : -1;
}
#endif

int container_seccomp_apply_i(char* config_json) {
#if defined(__linux__)
  if (config_json == NULL || !container_json_has_token(config_json, "\"seccomp\"") ||
      container_json_has_token(config_json, "\"seccomp\": null") ||
      container_json_has_token(config_json, "\"seccomp\":null")) {
    return 0;
  }
  if (container_dry_run()) {
    return 0;
  }
  return container_seccomp_install_default();
#else
  (void)config_json;
  return 0;
#endif
}

int container_eprint_i(char* msg) {
  if (msg == NULL) {
    return -1;
  }
  fputs(msg, stderr);
  fputc('\n', stderr);
  return 0;
}

void* container_buf_alloc_i(int nbytes) {
  if (nbytes <= 0) {
    return NULL;
  }
  return malloc((size_t)nbytes);
}

void container_buf_free_i(void* p) { free(p); }

int container_str_cmp_i(char* a, char* b) {
  if (a == NULL || b == NULL) {
    return (a == b) ? 0 : 1;
  }
  return strcmp(a, b);
}

int container_path_join_i(char* a, char* b, char* out, int cap) {
  if (a == NULL || b == NULL || out == NULL || cap <= 0) {
    return -1;
  }
  snprintf(out, (size_t)cap, "%s/%s", a, b);
  return (int)strlen(out);
}

int container_bundle_read_config_i(char* bundle_path, char* buf, int cap) {
  if (bundle_path == NULL || buf == NULL || cap <= 0) {
    return -1;
  }
  char path[1024];
  snprintf(path, sizeof(path), "%s/config.json", bundle_path);
  return container_read_file_i(path, buf, cap);
}

int container_bundle_rootfs_exists_i(char* bundle_path, char* config_json) {
  (void)config_json;
  if (bundle_path == NULL) {
    return 0;
  }
  char path[1024];
  snprintf(path, sizeof(path), "%s/rootfs", bundle_path);
  return container_file_exists_i(path);
}

int container_json_status_i(char* state_json, char* out, int cap) {
  return container_json_field_str_i(state_json, "status", out, cap);
}

int container_json_pid_i(char* state_json, char* out, char* has_pid) {
  char tmp[64];
  int n = container_json_field_int_i(state_json, "pid", tmp);
  if (n < 0) {
    if (has_pid != NULL) {
      *has_pid = 0;
    }
    return -1;
  }
  if (has_pid != NULL) {
    *has_pid = 1;
  }
  return container_copy_cstr(out, 64, tmp);
}

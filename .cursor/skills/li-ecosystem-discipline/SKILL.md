---
name: li-ecosystem-discipline
description: >-
  Cross-repo Li work — vision placement, engineering gates, CVE, Learned from,
  downstream pins, agent coordination. Use for httpd/lis, lip, lit, security,
  governance, or any change touching multiple repos or pillars.
---

# Li ecosystem discipline

Use when work spans **`lic`**, **`lip`**, **`lit`**, **`lis`**, or official **`li-*`** packages.

## Before coding

1. [engineering-standards.md](../../../docs/ecosystem/engineering-standards.md)
2. [vision-and-roadmap.md](../../../docs/ecosystem/vision-and-roadmap.md)
3. [agent-coordination.md](../../../docs/ecosystem/agent-coordination.md) — update `.li-agent-coord.json`
4. [governance plan](../../../docs/superpowers/plans/2026-05-16-li-ecosystem-governance.md) if creating org repos

## Per task checklist

- [ ] Vision in correct doc (master plan vs package vs httpd plan)
- [ ] **Learned from** 2–4 references documented
- [ ] **Functionality** — tests + spec ids
- [ ] **Security** — CVE catalog / exploit TOML row for attack surface
- [ ] **Performance** — bench or N/A with reason
- [ ] **Coverage tier** — std 100% / publish 80%
- [ ] Downstream `li-toolchain.toml` if `lic` API changed
- [ ] Human approval for org/secrets (master plan human-only rule)

## Related skills

- [create-li-package](../create-li-package/SKILL.md) — new packages
- [build-li-master-plan](../build-li-master-plan/SKILL.md) — compiler phases

## Do not

- Hide ecosystem vision only in a package README
- Skip CVE tests to merge faster
- Hand-roll `packages/` trees (use `li-new-package`)

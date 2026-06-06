# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `par_outer_product_elem`, `par_matmul_outer` kernels (WP-PAR-31).
- `ghost.li` 1D halo partition helpers and exchange sketch (WP-PAR-32).
- `li_parallel_selftest` and smoke `kernels_ghost.li` (T-PKG-li-parallel-kernels-ghost).
- `block_partition_begin` / `block_partition_end` on distributed surface.

### Fixed

- `proof.li` `disjoint_block` parse error (`||` → `return true`).

## [0.1.0] - 2026-06-06

### Added

- Package skeleton.

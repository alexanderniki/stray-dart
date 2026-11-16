# Project Roadmap: stray (SDD Roadmap)

This document formalizes the project decomposition and planning according to **Spec-Driven Development (SDD)** principles. Every feature evolves through a rigorous lifecycle: `Specification` $\rightarrow$ `Approval` $\rightarrow$ `Tests (Red)` $\rightarrow$ `Implementation (Green)` $\rightarrow$ `Refactor`.

---

## Phase 0. Architectural Foundation & MVP Core (✅ Completed)

- [x] **0.1. Project Constitution & Standards:**
  - Established architectural guardrails: [docs/constitution.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/constitution.md) / [docs/constitution.ru.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/constitution.ru.md).
  - Strict compiler and linter settings in [analysis_options.yaml](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/analysis_options.yaml).
  - Operational rules for AI assistants in [AGENTS.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/AGENTS.md).
- [x] **0.2. Product Brief:**
  - Codified core value, target audience (shell enthusiasts, Conky users), and constraints in [docs/brief.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/brief.md) / [docs/brief.ru.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/brief.ru.md).
- [x] **0.3. MVP Specification:**
  - Formulated 12 BDD acceptance scenarios in [spec/mvp.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/mvp.spec.md) / [spec/mvp.spec.ru.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/mvp.spec.ru.md).
- [x] **0.4. TDD Implementation (Red $\rightarrow$ Green Phase):**
  - Pure Hexagonal Architecture implemented: `core/`, `domain/`, `infrastructure/`, `cli/`.
  - 100% test pass rate across 30 unit and integration tests.
  - Native standalone binary compilation verified (`dart compile exe`).

---

## Phase 1. Initial Release Preparation: v0.1.0 (🎯 In Progress)

Goal: Package the tool for general availability and distribution.

- [ ] **1.1. User Documentation ([README.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/README.md)):**
  - Comprehensive CLI overview, quick start, options reference.
  - Real-world integration recipes for `.bashrc` / `.zshrc` / `config.fish` (startup quotes).
  - Integration recipe for desktop Conky widgets (timed updates with strict formatting).
- [ ] **1.2. Package Metadata:**
  - Configure [pubspec.yaml](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/pubspec.yaml) (add `executables`, repository metadata).
  - Maintain [CHANGELOG.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/CHANGELOG.md).
- [ ] **1.3. Cross-Platform CI/CD (GitHub Actions):**
  - `ci.yml`: Automated quality gates (`dart format`, `dart analyze`, `dart test`) on every PR/commit.
  - `release.yml`: Matrix native builds for **macOS (arm64/x64)**, **Linux (x64)**, and **Windows (x64)** attached to GitHub Releases.

---

## Phase 2. Core Architectural Optimization: v0.2.0 (⏳ Scheduled)

Goal: Ingest files of arbitrary size with bounded $O(1)$ memory consumption.

- [ ] **2.1. Streaming Ingestion Specification ([spec/streaming_reader.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/streaming_reader.spec.md)):**
  - Implement *Reservoir Sampling* (Algorithm R).
  - Bound memory usage to <15 MB RSS even on multi-gigabyte log files.
- [ ] **2.2. TDD (Red):** Streaming reader unit tests and statistical uniformity tests.
- [ ] **2.3. Implementation (Green):** Introduce `StreamingLineReader` in infrastructure and swap in Composition Root with zero domain changes.

---

## Phase 3. CLI Feature Expansion: v0.3.0+ (💡 Backlog)

Enhancements extending terminal workflow integration:

- [ ] **3.1. Standard Input (`stdin`) Support:**
  - Specification: [spec/stdin_support.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/stdin_support.spec.md)
  - Scenario: Reading from standard streams (`cat file.txt | stray -` or `curl -s URL | stray -`).
- [ ] **3.2. Multiple Line Selection (`-n, --count`):**
  - Specification: [spec/multiple_selection.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/multiple_selection.spec.md)
  - Scenario: Selecting $N$ random unique lines without replacement (similar to `shuf -n`).
- [ ] **3.3. ANSI Color Preservation During Formatting:**
  - Specification: [spec/ansi_formatting.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/ansi_formatting.spec.md)
  - Scenario: Calculate visual string width ignoring non-printable ANSI escape codes during truncation and wrapping.

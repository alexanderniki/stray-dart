# AGENTS.md — AI Agent Guidelines for `stray-dart`

Welcome to `stray-dart`. This document defines the operational contracts, architectural invariants, and development workflows that all AI agents must strictly follow when working in this repository.

---

## 1. Project Overview & Architecture

`stray` is a lightweight, reliable CLI utility in Dart that selects and outputs a random line from a text file, supporting truncation (`-t, --truncate`) and wrapping (`-w, --wrap`).

- **SDK:** Dart 3.14+ (Sound Null Safety, Strict Mode enabled).
- **Architecture:** Pragmatic Hexagonal Architecture (Ports & Adapters):
  - `lib/src/core/`: Foundational primitives (`Result<S, F>`, `AppError`).
  - `lib/src/domain/`: Pure Dart business logic (`StringPicker`, `StringFormatter`, ports `LineReader`, `RandomGenerator`). **NEVER import `dart:io` or external packages here.**
  - `lib/src/infrastructure/`: I/O adapters implementing domain ports (`FileLineReader`, `SystemRandomGenerator`).
  - `lib/src/cli/`: CLI runner, argument parsing with `package:args`, formatting, stream management (`stdout`/`stderr`), and exit code mappings.
  - `bin/stray_dart.dart`: Composition Root. Assembles dependencies via manual Constructor Injection.

---

## 2. Core Architectural Invariants (Non-Negotiable)

1. **Constitutional Alignment:** Refer to `docs/constitution.md` (and `docs/constitution.ru.md`) as the ultimate source of truth for architectural principles.
2. **Pure Domain:** The `domain/` layer must remain 100% pure Dart. No `dart:io`, no platform-dependent imports.
3. **Result Pattern for Error Handling:**
   - Do not use `throw` for expected domain or I/O failures.
   - Operations that can fail must return `Result<T, AppError>`.
   - `AppError` is a typed hierarchy mapped to user-facing messages and exit codes.
4. **Dependency Minimalism:**
   - Runtime dependencies must be kept minimal (only `package:args`).
   - Do NOT introduce external DI, state management, or functional libraries (`get_it`, `fpdart`, etc.).
   - Do NOT add dependencies to `pubspec.yaml` without explicit user permission.

---

## 3. Spec-Driven Development (SDD) & TDD Workflow

Agents must strictly execute work in the following order:

```
[Specification] ──> [User Approval] ──> [Tests (Red)] ──> [Implementation (Green)] ──> [Refactor]
```

1. **Specification First (`spec/<feature>.spec.md`):**
   - No production code may be written until the feature specification is created and approved by the user.
   - Specifications must define CLI contracts, edge cases, and BDD scenarios (`Given-When-Then`).
2. **Strict TDD (Red Phase):**
   - Write unit and/or integration tests first in `test/`.
   - Run `dart test` to verify that the new tests fail (RED) before writing production code.
3. **Implementation (Green Phase):**
   - Write the minimal code necessary to make the tests pass.
4. **Refactoring & Clean-up:**
   - Keep functions pure, small, and well-typed.
   - Maintain 100% test pass rate.

---

## 4. Quality Gates (Run Before Submitting Work)

Every agent turn that modifies code must pass all three quality gates:

```bash
# 1. Format code (80-char line limit)
dart format --output=none --set-exit-if-changed .

# 2. Static analysis (Strict Mode: strict-casts, strict-inference, strict-raw-types)
dart analyze

# 3. Automated tests (100% passing, 0 flaky tests)
dart test
```

---

## 5. Standard CLI & Development Commands

- **Run in development:**
  ```bash
  dart run bin/stray_dart.dart [flags] <file-path>
  ```
- **Compile standalone native AOT binary:**
  ```bash
  dart compile exe bin/stray_dart.dart -o stray
  ```
- **Run tests:**
  ```bash
  dart test
  ```
- **Update dependencies:**
  ```bash
  dart pub get
  ```

---

## 6. Exit Codes Reference

- `0`: Success (or `--help`, `--version`).
- `1`: User/input error (file missing/not found, empty file, invalid flags/arguments).
- `2`: Internal / unexpected system error.

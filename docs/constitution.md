# Constitution: stray-dart

## 1. Vision & Scope
`stray` is a lightweight, reliable, and fast command-line utility written in Dart, designed to randomly pick and print a line from a text file.

Core Values:
- **Predictability:** Deterministic behavior, transparent exit codes, and user-friendly error messages without unhandled stack traces.
- **Minimalism:** Zero external bloat, avoiding heavy third-party frameworks and transitive dependencies.
- **Reliability:** Strict adherence to Spec-Driven Development (SDD), with comprehensive test coverage for every scenario defined in the specifications.

---

## 2. Architectural Principles

### 2.1. Pragmatic Hexagonal Architecture (Layered Isolation)
The codebase is structured into strictly isolated layers with a unidirectional dependency flow:
1. **`domain/` (Business Logic):**
   - Pure Dart, strictly decoupled from `dart:io` and external packages.
   - Contains core selection logic (`StringPicker`), domain contracts/ports (`LineReader`, `RandomGenerator`), and domain entities.
2. **`infrastructure/` (I/O Adapters):**
   - Implementations of I/O interfaces via `dart:io` (`FileLineReader`) and system random number generators.
3. **`cli/` (Command-Line Interface):**
   - Parsing CLI flags and arguments (`package:args`).
   - Input validation.
   - Mapping domain results and errors to human-readable console output and process exit codes.
4. **`bin/stray_dart.dart` (Composition Root):**
   - Application entry point.
   - Exclusively responsible for assembling the dependency graph (manual Constructor Injection) and delegating execution to the CLI runner.

### 2.2. Error Handling (Result Pattern)
- No unhandled exceptions (`throw`) for expected business scenarios or I/O failures. Exceptions are strictly reserved for critical programming bugs and unrecoverable assertions.
- All operations prone to failure return a lightweight `Result<T, AppError>` type (with `Success` and `Failure` variants).
- Typed domain errors (`AppError`) are hierarchical and carry sufficient context to provide clear, actionable feedback to the user.

### 2.3. Immutability & Pure Functions
- Domain entities and configuration objects must be `immutable`, utilizing `final` fields and `const` constructors wherever possible.
- Domain logic algorithms must be designed as pure functions depending solely on their explicit arguments.

---

## 3. Code Quality & Standards

### 3.1. Static Analysis & Type Safety
- Base ruleset: `package:lints/recommended.yaml`.
- Strict analysis mode enabled in `analysis_options.yaml`:
  ```yaml
  analyzer:
    language:
      strict-casts: true
      strict-inference: true
      strict-raw-types: true
  ```
- Zero tolerance for implicit `dynamic` (untyped external APIs must be immediately cast to strictly typed models).
- Full Sound Null Safety compliance (the `!` bang operator is banned unless preceded by an explicit null check).

### 3.2. Style & Formatting
- All code must be formatted using the official `dart format` tool (80-character line limit).
- No unused imports or variables.
- Public layer APIs must be documented with concise Dartdoc comments (`///`).

---

## 4. Spec-Driven Development (SDD) & Testing Strategy

### 4.1. Feature Development Lifecycle
Every new feature or contract modification must strictly adhere to the following sequence:
1. **Specification (`spec/<feature>.spec.md`):** Define requirements, CLI input/output contracts, edge cases, and acceptance scenarios.
2. **Approval:** The specification must be reviewed and approved by the lead architect.
3. **Tests (Red):** Write unit and/or integration tests for all defined scenarios (tests must fail).
4. **Implementation (Green):** Write the minimal production code necessary to make the tests pass.
5. **Refactoring:** Clean up and optimize the implementation while maintaining passing tests and clean `dart analyze` reports.

### 4.2. Specification Format
Every specification in `spec/` must include:
- **Context & Goals:** Purpose and scope of the feature.
- **CLI & I/O Contracts:** Expected flags, positional arguments, output formats, and exit codes.
- **Edge Cases:** Empty files, missing read permissions, CRLF/LF line endings, multi-byte UTF-8 characters.
- **Acceptance Scenarios:** BDD-style scenarios (`Given` initial state, `When` action occurs, `Then` expected outcome).

### 4.3. Test Pyramid & Determinism
- **Unit Tests (Domain):** Validate line selection logic in complete isolation using `FakeLineReader` and a deterministic `Random` instance (with a fixed seed).
- **Integration / E2E Tests (CLI):** Execute commands against actual temporary files (`Directory.systemTemp`), validating `stdout`, `stderr`, and exit code behavior.
- All tests must run fast (<2 seconds for the full suite) and be 100% deterministic (zero flaky tests).

---

## 5. Dependency Policy

- **Minimalist Runtime Dependencies:** Only official, essential packages for CLI functionality are permitted (currently `args: ^2.7.0`).
- **In-House Lightweight Patterns:** The `Result<T, E>` type and dependency injection must be written in pure Dart without pulling in heavy third-party libraries (e.g., `fpdart`, `get_it`).
- Adding any new dependency to `pubspec.yaml` requires explicit architectural justification and user approval.

---

## 6. CLI Technical Standards & Constraints

### 6.1. Process Exit Codes (Simplified Standard)
- `0`: Success.
- `1`: User/input error (e.g., file not found, empty file, invalid CLI arguments).
- `2`: Internal / unexpected system error.

### 6.2. Stream Separation (I/O)
- `stdout`: Strictly for primary output (the chosen random line, `--help` text, `--version` information).
- `stderr`: Strictly for diagnostics and error messages (prefixed with `Error: ...`).
- Full compatibility with Unix pipelines (`stray file.txt | cat`).

### 6.3. Cross-Platform Compatibility & Encoding
- File encoding: strictly UTF-8.
- Line ending normalization: robust handling of both Unix (`\n`) and Windows (`\r\n`).
- Cross-platform file path resolution across macOS, Linux, and Windows.
- Support both JIT execution (`dart run`) and native AOT binary compilation (`dart compile exe`).

### 6.4. Data Ingestion Evolution
- **MVP Phase:** In-memory file reading (`List<String>`) via `FileLineReader`.
- **Future Optimization:** Upgrading `LineReader` to stream processing (*Reservoir Sampling*) with $O(1)$ memory complexity to support arbitrarily large files. Thanks to the domain port interface, this transition will require zero changes to domain or CLI logic.

---

## 7. AI Collaboration Contract

1. **No Code Without an Approved Spec:** The AI agent must never implement or modify feature code until the corresponding specification in `spec/` is explicitly approved by the user.
2. **Strict TDD Compliance:** The AI agent must write failing tests first, verify their failure, and only then proceed with the implementation.
3. **Architectural Guardrails:**
   - The AI agent must never import `dart:io` within the `domain/` layer.
   - The AI agent must never add dependencies to `pubspec.yaml` without prior consent.
   - The AI agent must not alter public contracts or interfaces without explicit discussion.
4. **Quality Gates:**
   Before handing off any step, the AI agent must verify that:
   - `dart format` is applied to all modified files.
   - `dart analyze` passes with 0 warnings and 0 errors.
   - `dart test` passes with 100% success.


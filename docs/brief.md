# Project Brief: stray

## 1. Problem Statement
In terminal and command-line environments, users frequently need to pick a random line from a text file: a quote of the day, tip, reminder, or test data item. Existing standard tools (such as `shuf`, `fortune`, or ad-hoc combinations of `awk`/`fold`/`cut`) have notable drawbacks:
- **Cross-Platform Inconsistency:** Standard GNU utilities like `shuf` are not available out-of-the-box on macOS and Windows, or feature incompatible flag syntaxes.
- **Cumbersome Text Formatting:** Constraining line length or wrapping text requires fragile, multi-stage shell pipelines (`shuf -n 1 file.txt | fold -s -w 40 | head -n ...`).
- **Distribution Overhead:** Script-based solutions (e.g., Python) require an installed runtime environment and external dependencies.

**`stray`** solves this by providing an ultra-lightweight, predictable, cross-platform command-line utility compiled into a single self-contained native binary with zero external runtime dependencies, featuring built-in, graceful text formatting (wrapping and truncation with ellipsis).

---

## 2. Target Audience
1. **Terminal Enthusiasts:** Users customizing their shell startup experience (MOTD in `.bashrc`, `.zshrc`, `config.fish`), displaying random tips, daily quotes, or reminders upon opening a terminal session.
2. **Desktop Widget & Status Bar Users (Conky, Polybar, Waybar, etc.):** Users rendering dynamic text on their desktop or status panels, where strict line limits and wrapping are essential to prevent widget UI clipping or overflow.
3. **Developers & System Administrators:** Engineers seeking standalone, single-binary CLI tools that behave identically across operating systems.

---

## 3. Core Use Cases
1. **Welcome Message on Shell Session Startup:**
   When a new terminal window or tab opens, `stray` is executed from the shell configuration file to display a random quote, tip, or note fitted to the terminal's width.
2. **Periodic Display in Conky and Status Panels:**
   Executing `stray` on an interval (e.g., every 10 minutes) to render a random entry from a notes or task file within a restricted screen widget area.
3. **Reproducible Workflows via Deterministic Seed:**
   Supplying `--seed <int>` during demonstrations, automated integration tests, or deterministic shell scripts where repeatable output is required.

---

## 4. MVP Scope
- **Local File Ingestion:** Reading UTF-8 encoded files from a provided file path, with transparent support for both Unix (`\n`) and Windows (`\r\n`) line endings.
- **Random Line Selection:** Selecting exactly one non-empty line.
- **Deterministic Execution:** The `--seed <int>` flag for fixed pseudo-random number generation.
- **Text Formatting:**
  - Truncating long lines (`-t, --truncate <int>`) with an appended ellipsis (`…`).
  - Line wrapping (`-w, --wrap <int>`).
  - Consistent combined behavior (`width < truncate` and `width >= truncate`).
- **Strict CLI Contracts:**
  - Clean stream separation: primary output to `stdout`, errors and diagnostics to `stderr`.
  - Predictable exit codes: `0` (success), `1` (user/file error), `2` (system failure).
  - Standard options: `-h, --help` and `-v, --version`.

---

## 5. Out of Scope for MVP
- **Standard Input (`stdin`) Support:** Pipeline processing (e.g., `cat file.txt | stray`) is deferred to subsequent versions.
- **Multiple Line Selection (`-n <count>`):** The MVP strictly returns a single line.
- **Weighted Selection:** No support for frequency/probability weights for lines.
- **Content Filtering:** No regex pattern matching or substring filtering prior to selection.
- **Streaming Ingestion ($O(1)$ Reservoir Sampling):** The architectural port is designed for future streaming, but MVP reads the file into memory.

---

## 6. MVP Success Criteria
1. **Single-Binary Portability:** Compiles into a completely standalone native executable with zero external runtime dependencies and no requirement for an installed Dart SDK on the target machine.
2. **Cross-Platform Availability:** Verified functionality and distribution builds for all three major platforms: **Linux**, **macOS**, and **Windows**.
3. **100% Test Pass Rate:** Complete test coverage for all BDD acceptance scenarios defined in the specification (`dart test`).
4. **Sub-Millisecond Cold Start:** Instantaneous launch time, undetectable to the human eye when opening a terminal tab or triggered periodically from `conky`.

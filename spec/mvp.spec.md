# Specification: MVP - Random Line Picker (`stray`)

## 1. Context & Goals
The purpose of the MVP release of `stray` is to provide a reliable, minimal CLI utility that reads a UTF-8 text file, randomly selects one line, and outputs it to `stdout`.

---

## 2. CLI Interface & Contract

### 2.1. Invocation Syntax
```bash
stray [flags] <file-path>
```

### 2.2. Positional Arguments
- `<file-path>` (Required): Path to the target text file. Exactly one positional argument is allowed.

### 2.3. Options & Flags
- `-h`, `--help`: Prints usage help to `stdout` and exits with code `0`.
- `-v`, `--version`: Prints tool version to `stdout` and exits with code `0`.
- `-t`, `--truncate <int>`: Truncates long text lines after the specified number of characters, appending an ellipsis (`…`).
- `-w`, `--wrap <int>`: Wraps the line by inserting a newline after the specified number of characters.
- `--seed <int>` (Optional): Seeds the pseudo-random number generator for deterministic line selection (primarily for testing and reproducible CLI scripts).

### 2.4. Exit Codes
- `0`: Successful execution (or `--help` / `--version`).
- `1`: User/input error (missing argument, file not found, unreadable file, empty file, invalid seed/truncate/wrap value, unknown flags).
- `2`: Unexpected internal runtime failure.

### 2.5. Standard Streams
- `stdout`:
  - Contains solely the selected line (with optional truncation/wrapping, followed by a newline), or help/version info.
- `stderr`:
  - Contains error messages prefixed with `Error: <message>`.

---

## 3. Edge Cases & Requirements

1. **Line Ending Normalization:** Both Unix (`\n`) and Windows (`\r\n`) line endings must be properly stripped from the output line before formatting.
2. **Trailing Newlines:** A file ending with or without a trailing newline must not affect line count. An empty trailing line caused by a final `\n` is not treated as a line candidate.
3. **Empty Files:** A file with 0 bytes, or containing exclusively newline characters (`\n`, `\r\n`), is considered empty. Must return exit code `1` with message `Error: File is empty`.
4. **Single-Line Files:** If the file contains exactly one line, that line must always be selected regardless of the random seed.
5. **UTF-8 Encoding:** Multi-byte characters (Unicode, emojis, non-Latin alphabets) must be preserved without distortion.
6. **Directory Path:** If `<file-path>` points to a directory rather than a file, return exit code `1` with message `Error: Path is a directory`.
7. **Non-Existent File:** Return exit code `1` with message `Error: File not found: <path>`.
8. **Line Truncation (`-t`, `--truncate <int>`):** If specified, lines exceeding the given character count are truncated after that count and appended with an ellipsis character (`…`). If line length is less than or equal to the count, the line is unmodified. Must be a positive integer (> 0).
9. **Line Wrapping (`-w`, `--wrap <int>`):** If specified, lines are wrapped to a new line after the specified number of characters. Must be a positive integer (> 0).
10. **Combined Wrapping and Truncation:** Both `-t` (`--truncate`) and `-w` (`--wrap`) can be applied simultaneously according to the following rules:
    - **Case 1 (`width < truncate`):** The text is wrapped to a new line every `width` characters, and truncated with an ellipsis (`…`) once the cumulative character count reaches `truncate`.
    - **Case 2 (`width >= truncate`):** The `width` parameter is ignored; the text is truncated strictly according to `truncate`.

---

## 4. Acceptance Scenarios (BDD)

### Scenario 1: Successfully select and print a random line
- **Given** a file `quotes.txt` with lines:
  ```
  Line 1
  Line 2
  Line 3
  ```
- **When** the user runs `stray quotes.txt`
- **Then** the exit code is `0`
- **And** `stdout` contains one of the lines from `quotes.txt` followed by a newline
- **And** `stderr` is empty

### Scenario 2: Deterministic selection with `--seed`
- **Given** a file `items.txt` with lines `A`, `B`, `C`, `D`, `E`
- **When** the user runs `stray --seed 42 items.txt` multiple times
- **Then** the exit code is `0` on each run
- **And** `stdout` outputs the exact same line on every run for seed `42`

### Scenario 3: Missing file path argument
- **When** the user runs `stray` without arguments
- **Then** the exit code is `1`
- **And** `stderr` contains `Error: Missing required file path`
- **And** `stderr` prints the usage instructions

### Scenario 4: File does not exist
- **When** the user runs `stray non_existent.txt`
- **Then** the exit code is `1`
- **And** `stderr` contains `Error: File not found: non_existent.txt`

### Scenario 5: Empty file
- **Given** an empty file `empty.txt` (0 bytes)
- **When** the user runs `stray empty.txt`
- **Then** the exit code is `1`
- **And** `stderr` contains `Error: File is empty`

### Scenario 6: File contains only newlines
- **Given** a file `blanks.txt` containing only `\n\n\n`
- **When** the user runs `stray blanks.txt`
- **Then** the exit code is `1`
- **And** `stderr` contains `Error: File is empty`

### Scenario 7: UTF-8 encoding support
- **Given** a file `unicode.txt` with lines:
  ```
  Привет, мир! 🚀
  你好，世界！
  ```
- **When** the user runs `stray unicode.txt`
- **Then** the exit code is `0`
- **And** `stdout` contains one of the Unicode lines intact

### Scenario 8: Help and Version options
- **When** the user runs `stray --help` or `stray -h`
- **Then** the exit code is `0`
- **And** `stdout` contains usage and option descriptions
- **When** the user runs `stray --version` or `stray -v`
- **Then** the exit code is `0`
- **And** `stdout` contains the version number

### Scenario 9: Line truncation with `-t` / `--truncate`
- **Given** a file `long.txt` with line:
  ```
  The quick brown fox jumps over the lazy dog
  ```
- **When** the user runs `stray -t 15 long.txt`
- **Then** the exit code is `0`
- **And** `stdout` contains `The quick brown…` followed by a newline

### Scenario 10: Line wrapping with `-w` / `--wrap`
- **Given** a file `wrap.txt` with line:
  ```
  ABCDEFGHIJ
  ```
- **When** the user runs `stray -w 4 wrap.txt`
- **Then** the exit code is `0`
- **And** `stdout` contains:
  ```
  ABCD
  EFGH
  IJ
  ```

### Scenario 11: Combined wrapping and truncation (`width < truncate`)
- **Given** a file `combined.txt` with line:
  ```
  ABCDEFGHIJKLMN
  ```
- **When** the user runs `stray -w 4 -t 10 combined.txt`
- **Then** the exit code is `0`
- **And** `stdout` contains:
  ```
  ABCD
  EFGH
  IJ…
  ```

### Scenario 12: Combined wrapping and truncation (`width >= truncate`)
- **Given** a file `combined.txt` with line:
  ```
  ABCDEFGHIJKLMN
  ```
- **When** the user runs `stray -w 10 -t 5 combined.txt`
- **Then** the exit code is `0`
- **And** `stdout` contains `ABCDE…` followed by a newline (width is ignored)

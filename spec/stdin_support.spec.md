# Specification: Standard Input (`stdin`) Support

## 1. Context & Goals
To seamlessly integrate `stray` into UNIX shell pipelines, users need the ability to pass text via standard input (`stdin`) rather than specifying an explicit on-disk file path (e.g., `cat list.txt | stray -` or `curl -s https://example.com/quotes | stray -`).

---

## 2. CLI Interface & Contract

### 2.1. Invocation Syntax
```bash
# Explicit dash denoting stdin:
stray [flags] -

# Implicit pipe detection (when stdin is not a terminal and no path argument is provided):
command | stray [flags]
```

### 2.2. Positional Arguments
- `<file-path>`: If passed as `-`, standard input (`stdin`) is ingested instead of a file on disk.
- If no argument is passed AND `stdin` has input piped into it (non-terminal `stdin`), `stdin` is automatically selected.
- If no argument is passed AND `stdin` is a TTY terminal, returns error `1` with usage info.

### 2.3. Exit Codes
- `0`: Success (random line chosen from stdin and output to `stdout`).
- `1`: User/input error (stdin is empty, invalid flags).
- `2`: System error (broken pipe or I/O failure).

---

## 3. Acceptance Scenarios (BDD)

### Scenario 1: Explicit stdin dash (`-`)
- **Given** an input stream with lines `Alfa`, `Beta`, `Gamma` piped into `stray`
- **When** the user runs `stray -`
- **Then** exit code is `0`
- **And** `stdout` contains one of `Alfa`, `Beta`, or `Gamma`

### Scenario 2: Pipeline execution with options
- **Given** an input stream with line `A very long line exceeding truncate threshold`
- **When** the user runs `echo "..." | stray -t 10 -`
- **Then** exit code is `0`
- **And** `stdout` contains truncated output with `…`

### Scenario 3: Empty standard input
- **Given** an empty input stream (`echo -n ""`)
- **When** the user runs `stray -`
- **Then** exit code is `1`
- **And** `stderr` contains `Error: Standard input is empty`

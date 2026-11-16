# Specification: Multiple Line Selection (`-n, --count`)

## 1. Context & Goals
While the MVP selects exactly one random line, common CLI use cases (such as selecting a sample of items, picking 3 quotes, or drawing random lottery tickets) require selecting $N$ lines.

This feature introduces the `-n, --count <int>` flag, enabling sampling of multiple distinct lines from a file or stream.

---

## 2. CLI Interface & Contract

### 2.1. Flags & Options
- `-n, --count <int>`: Number of random lines to select. Must be a strictly positive integer ($n \ge 1$). Default: `1`.

### 2.2. Selection Logic (Without Replacement)
- Lines are selected **without replacement** (no line can be selected more than once in a single run).
- If the requested count $n$ exceeds the number of available lines $M$ ($n > M$), all $M$ lines are returned in a randomized order.
- Each selected line is individually processed according to any active formatting flags (`-t`, `-w`).

### 2.3. Exit Codes
- `0`: Success (selected lines printed to `stdout`).
- `1`: Invalid count argument (non-integer, $\le 0$) or file error.

---

## 3. Acceptance Scenarios (BDD)

### Scenario 1: Select multiple distinct lines
- **Given** a file `fruits.txt` containing 5 unique lines: `Apple`, `Banana`, `Cherry`, `Date`, `Elderberry`
- **When** the user runs `stray -n 3 fruits.txt`
- **Then** exit code is `0`
- **And** `stdout` contains exactly 3 distinct lines from `fruits.txt`
- **And** no duplicate lines appear in output

### Scenario 2: Count exceeds available lines count
- **Given** a file `two.txt` with lines `Line 1` and `Line 2`
- **When** the user runs `stray -n 5 two.txt`
- **Then** exit code is `0`
- **And** `stdout` outputs both lines in randomized order

### Scenario 3: Invalid count value
- **When** the user runs `stray -n 0 fruits.txt` or `stray -n -3 fruits.txt`
- **Then** exit code is `1`
- **And** `stderr` contains `Error: Invalid value for --count: must be a positive integer`

### Scenario 4: Multiple lines with formatting flags
- **Given** a file with long lines
- **When** the user runs `stray -n 2 -t 10 long.txt`
- **Then** exit code is `0`
- **And** both printed lines are truncated to 10 characters with an appended ellipsis

# Specification: ANSI Escape Sequence Preservation

## 1. Context & Goals
When `stray` is used to display stylized text (e.g., from `conky`, `lolcat`, or files containing terminal color codes), standard string slicing operations (`substring`) treat non-printable ANSI escape sequences as regular characters. This results in two major bugs:
1. **Premature Truncation/Wrap:** Lines appear visually shorter than configured because escape characters consume length allowance.
2. **Color Bleed / Corruption:** Cutting in the middle of a colored block or wrapping without resetting leaves terminal styles open, corrupting downstream terminal output.

The goal of this feature is to ensure `StringFormatter` calculates visual length ignoring ANSI sequences and properly restores styling across wrapped/truncated fragments.

---

## 2. Requirements & Behavior

### 2.1. Visual Length Calculation
- ANSI escape sequences matching `\x1B\[[0-9;]*[a-zA-Z]` must not count towards the visible character length for truncation (`-t`) and wrapping (`-w`).

### 2.2. Style Integrity Across Chunks
- If a line is wrapped across multiple terminal lines, any active styles must be cleanly reset at the end of each chunk and restored at the beginning of the subsequent chunk.
- If a line is truncated with an ellipsis (`…`), an ANSI reset code (`\x1B[0m`) must be appended immediately following the ellipsis to avoid bleeding colors into the user's prompt.

---

## 3. Acceptance Scenarios (BDD)

### Scenario 1: Truncation respects visible width
- **Given** an input containing a red-colored word: `\x1B[31mHello\x1B[0m World` (visible width: 11 characters)
- **When** `stray` truncates to visible width 8
- **Then** the visible output text is `Hello Wo…`
- **And** the word `Hello` retains its red color formatting
- **And** the string ends with a color reset `\x1B[0m`

### Scenario 2: Wrapping preserves styles across lines
- **Given** an input with a single continuous color style: `\x1B[32mABCDEFGH\x1B[0m`
- **When** `stray` wraps the line at width 4
- **Then** line 1 (`ABCD`) and line 2 (`EFGH`) both render in green without terminal leakage

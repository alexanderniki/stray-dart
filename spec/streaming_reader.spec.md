# Specification: Streaming Line Ingestion (Reservoir Sampling)

## 1. Context & Goals
In the MVP release, `stray` reads the target file completely into memory (`List<String>`). While acceptable for small files (quotes, tasks), files exceeding available RAM (multi-gigabyte logs, dictionaries) can trigger Out-Of-Memory (OOM) crashes.

The goal of this feature is to enable stream processing using **Reservoir Sampling (Algorithm R)**, achieving **$O(1)$ spatial complexity** and **$O(N)$ single-pass time complexity** without changing public domain or CLI behavior.

---

## 2. Technical Architecture & Contract

### 2.1. Ingestion Interface
- The `LineReader` port or an enhanced `StreamingLineReader` adapter processes the file as a lazy, chunked byte stream (`File.openRead()`) transformed through `utf8.decoder` and `LineSplitter`.
- Candidate lines are evaluated sequentially on the fly.

### 2.2. Sampling Algorithm
For a stream of non-empty lines with total count $N$:
1. The first valid line is chosen as the reservoir candidate with probability $1$.
2. For the $i$-th valid line ($i \ge 2$), it replaces the current candidate with probability $1 / i$.
3. When the stream terminates, every line has had an equal probability $1 / N$ of being chosen.

### 2.3. Resource Constraints
- **Peak Memory (RSS):** Must not exceed 20 MB regardless of file size (tested up to multi-gigabyte files).
- **Determinism:** When a fixed `--seed <int>` is supplied, identical random sequence steps produce identical selections on repeated stream passes.

---

## 3. Acceptance Scenarios (BDD)

### Scenario 1: Uniform distribution on stream
- **Given** a stream of 1,000 distinct lines
- **When** `stray` processes the stream repeatedly with a randomized seed
- **Then** every line has a uniform probability $1/1000$ of selection within statistical tolerance

### Scenario 2: Deterministic selection on stream with `--seed`
- **Given** a large file `large_dataset.txt`
- **When** `stray --seed 12345 large_dataset.txt` is executed multiple times
- **Then** the exact same line is returned on every execution

### Scenario 3: Memory footprint constraint
- **Given** a file `huge.txt` of size 500 MB (several million lines)
- **When** `stray huge.txt` executes
- **Then** execution succeeds with exit code `0`
- **And** peak memory usage does not exceed 20 MB

### Scenario 4: Stream contains only newlines or whitespace
- **Given** a stream where every line is empty or whitespace
- **When** `stray` finishes processing
- **Then** exit code is `1`
- **And** `stderr` contains `Error: File is empty`

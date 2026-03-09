# StringTemplates.jl Benchmark Report

Generated: 2026-03-09T08:50:32.746

```
Julia Version 1.12.5
Commit 5fe89b8ddc1 (2026-02-09 16:05 UTC)
Build Info:
  Official https://julialang.org release
Platform Info:
  OS: macOS (arm64-apple-darwin24.0.0)
  CPU: 10 × Apple M1 Pro
  WORD_SIZE: 64
  LLVM: libLLVM-18.1.7 (ORCJIT, apple-m1)
  GC: Built with stock GC
Threads: 8 default, 1 interactive, 8 GC (on 8 virtual cores)
Environment:
  JULIA_NUM_THREADS = auto
```

## Time (minimum)

| Benchmark | StringTemplates | Mustache | Base | vs Mustache | vs Base |
|:----------|----------------:|---------:|-----:|------------:|--------:|
| Small (2 vars, string return) | 316.983 ns | 2.639 μs | 166.831 ns | 8.3x | 0.5x |
| Mostly-static (2 vars in text, string return) | 373.576 ns | 4.488 μs | 260.574 ns | 12.0x | 0.7x |
| Many vars, int values (string return) | 4.464 μs | 31.291 μs | 2.866 μs | 7.0x | 0.6x |
| Many vars, string values (string return) | 3.863 μs | 31.166 μs | 2.097 μs | 8.1x | 0.5x |
| Many vars, int values (IO write) | 4.470 μs | 31.917 μs | 1.692 μs | 7.1x | 0.4x |
| Many vars, string values (IO write) | 3.698 μs | 31.166 μs | 395.624 ns | 8.4x | 0.1x |

## Memory (bytes and allocations)

| Benchmark | StringTemplates | Mustache | Base |
|:----------|----------------:|---------:|-----:|
| Small (2 vars, string return) | 1.50 KiB (17) | 848 bytes (12) | 640 bytes (15) |
| Mostly-static (2 vars in text, string return) | 1.70 KiB (17) | 2.36 KiB (44) | 1.84 KiB (21) |
| Many vars, int values (string return) | 8.97 KiB (91) | 3.14 KiB (30) | 2.55 KiB (56) |
| Many vars, string values (string return) | 8.83 KiB (41) | 3.14 KiB (30) | 1.16 KiB (2) |
| Many vars, int values (IO write) | 8.09 KiB (79) | 2.98 KiB (27) | 2.83 KiB (53) |
| Many vars, string values (IO write) | 7.21 KiB (27) | 2.98 KiB (27) | 1.92 KiB (0) |

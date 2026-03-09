# StringTemplates.jl Benchmark Report

Generated: 2026-03-09T10:34:59.133

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
| Small (2 vars, string return) | 317.156 ns | 2.708 μs | 173.505 ns | 8.5x | 0.5x |
| Mostly-static (2 vars in text, string return) | 367.262 ns | 4.607 μs | 258.997 ns | 12.5x | 0.7x |
| Many vars, int values (string return) | 4.381 μs | 32.041 μs | 3.130 μs | 7.3x | 0.7x |
| Many vars, string values (string return) | 3.812 μs | 32.584 μs | 2.056 μs | 8.5x | 0.5x |
| Many vars, int values (IO write) | 4.232 μs | 30.917 μs | 1.896 μs | 7.3x | 0.4x |
| Many vars, string values (IO write) | 3.630 μs | 31.334 μs | 391.708 ns | 8.6x | 0.1x |

## Memory (bytes and allocations)

| Benchmark | StringTemplates | Mustache | Base | vs Mustache | vs Base |
|:----------|----------------:|---------:|-----:|------------:|--------:|
| Small (2 vars, string return) | 1.50 KiB (17) | 848 bytes (12) | 640 bytes (15) | 1.8x | 2.4x |
| Mostly-static (2 vars in text, string return) | 1.70 KiB (17) | 2.36 KiB (44) | 1.84 KiB (21) | 0.7x | 0.9x |
| Many vars, int values (string return) | 8.97 KiB (91) | 3.14 KiB (30) | 2.55 KiB (56) | 2.9x | 3.5x |
| Many vars, string values (string return) | 8.83 KiB (41) | 3.14 KiB (30) | 1.16 KiB (2) | 2.8x | 7.6x |
| Many vars, int values (IO write) | 8.09 KiB (79) | 2.98 KiB (27) | 2.83 KiB (53) | 2.7x | 2.9x |
| Many vars, string values (IO write) | 7.21 KiB (27) | 2.98 KiB (27) | 1.92 KiB (0) | 2.4x | 3.8x |

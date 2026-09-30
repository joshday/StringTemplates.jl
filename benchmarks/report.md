# StringTemplates.jl Benchmark Report

Generated: 2026-09-30T13:24:33.748

```
Julia Version 1.13.1
Commit 96ca370cf0e (2026-09-25 19:34 UTC)
Build Info:
  Official https://julialang.org release
Platform Info:
  OS: macOS (arm64-apple-darwin27.0.0)
  CPU: 10 × Apple M1 Pro
  WORD_SIZE: 64
  LLVM: libLLVM-20.1.8 (ORCJIT, apple-m1)
  GC: Built with stock GC
Threads: 10 default, 1 interactive, 10 GC (on 10 virtual cores)
Environment:
  JULIA_NUM_THREADS = auto
```

## Time (minimum)

| Benchmark | StringTemplates | Mustache | Base | vs Mustache | vs Base |
|:----------|----------------:|---------:|-----:|------------:|--------:|
| Small (2 vars, string return) | 129.957 ns | 7.271 μs | 282.106 ns | 55.9x | 2.2x |
| Mostly-static (2 vars in text, string return) | 145.311 ns | 7.479 μs | 433.000 ns | 51.5x | 3.0x |
| Many vars, int values (string return) | 1.183 μs | 90.750 μs | 3.708 μs | 76.7x | 3.1x |
| Many vars, string values (string return) | 470.391 ns | 93.125 μs | 2.398 μs | 198.0x | 5.1x |
| Many vars, int values (IO write) | 1.192 μs | 90.083 μs | 1.946 μs | 75.6x | 1.6x |
| Many vars, string values (IO write) | 447.601 ns | 91.834 μs | 458.755 ns | 205.2x | 1.0x |

## Memory (bytes and allocations)

| Benchmark | StringTemplates | Mustache | Base | vs Mustache | vs Base |
|:----------|----------------:|---------:|-----:|------------:|--------:|
| Small (2 vars, string return) | 304 bytes (8) | 3.17 KiB (82) | 256 bytes (7) | 0.1x | 1.2x |
| Mostly-static (2 vars in text, string return) | 640 bytes (6) | 3.55 KiB (78) | 608 bytes (5) | 0.2x | 1.1x |
| Many vars, int values (string return) | 2.31 KiB (56) | 32.39 KiB (914) | 2.55 KiB (56) | 0.1x | 0.9x |
| Many vars, string values (string return) | 864 bytes (4) | 32.25 KiB (864) | 1.16 KiB (2) | 0.0x | 0.7x |
| Many vars, int values (IO write) | 2.83 KiB (53) | 32.23 KiB (911) | 2.83 KiB (53) | 0.1x | 1.0x |
| Many vars, string values (IO write) | 1.96 KiB (0) | 32.09 KiB (861) | 1.98 KiB (0) | 0.1x | 1.0x |

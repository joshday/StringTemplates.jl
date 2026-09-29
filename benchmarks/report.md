# StringTemplates.jl Benchmark Report

Generated: 2026-09-29T09:56:48.233

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
| Small (2 vars, string return) | 128.527 ns | 7.177 μs | 278.523 ns | 55.8x | 2.2x |
| Mostly-static (2 vars in text, string return) | 139.487 ns | 7.365 μs | 382.182 ns | 52.8x | 2.7x |
| Many vars, int values (string return) | 1.179 μs | 89.167 μs | 3.521 μs | 75.6x | 3.0x |
| Many vars, string values (string return) | 471.515 ns | 91.209 μs | 2.403 μs | 193.4x | 5.1x |
| Many vars, int values (IO write) | 1.204 μs | 89.167 μs | 1.908 μs | 74.0x | 1.6x |
| Many vars, string values (IO write) | 447.394 ns | 91.250 μs | 456.853 ns | 204.0x | 1.0x |

## Memory (bytes and allocations)

| Benchmark | StringTemplates | Mustache | Base | vs Mustache | vs Base |
|:----------|----------------:|---------:|-----:|------------:|--------:|
| Small (2 vars, string return) | 304 bytes (8) | 3.17 KiB (82) | 256 bytes (7) | 0.1x | 1.2x |
| Mostly-static (2 vars in text, string return) | 640 bytes (6) | 3.55 KiB (78) | 608 bytes (5) | 0.2x | 1.1x |
| Many vars, int values (string return) | 2.31 KiB (56) | 32.39 KiB (914) | 2.55 KiB (56) | 0.1x | 0.9x |
| Many vars, string values (string return) | 864 bytes (4) | 32.25 KiB (864) | 1.16 KiB (2) | 0.0x | 0.7x |
| Many vars, int values (IO write) | 2.83 KiB (53) | 32.23 KiB (911) | 2.83 KiB (53) | 0.1x | 1.0x |
| Many vars, string values (IO write) | 1.96 KiB (0) | 32.09 KiB (861) | 1.96 KiB (0) | 0.1x | 1.0x |

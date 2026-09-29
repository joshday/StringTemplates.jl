# StringTemplates

[![Build Status](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/joshday/StringTemplates.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/joshday/StringTemplates.jl)


<p align="center"><b>Speedy customizable string interpolation for Julia.</b></p>

## Usage

```julia
using StringTemplates, JSON3

# Here's a template.  It uses Julia's interpolation syntax.
t = @template "PlotlyJS.newPlot(\"my_id\", $data, {}, {})"

# `render` with anything that has Symbol keys or with keyword arguments
render(t, data = "[{\"y\": [1, 2]}]")
# "PlotlyJS.newPlot(\"my_id\", [{\"y\":[1,2]}], {}, {})"

# Alternatively, you can provide a custom print function
t2 = @template "PlotlyJS.newPlot(\"my_id\", $data, {}, {})" JSON3.write

render(t2, data=[(; y=1:2)])
# "PlotlyJS.newPlot(\"my_id\", [{\"y\":[1,2]}], {}, {})"

# Properties can be typed with `$(name::T)`.  Values are checked against the type
t3 = @template "x = $(x::Int)"

render(t3, x=1)
# "x = 1"
```

## Benchmarks

In the benchmarks at `benchmarks/suite.jl` (see `benchmarks/report.md`, Julia 1.13) we find that **StringTemplates** is:

- 1.0 - 5.1x faster than [Base string interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).
- 53 - 204x faster than [Mustache.jl](https://github.com/jverzani/Mustache.jl) (v1.1).

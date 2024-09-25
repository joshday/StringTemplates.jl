# StringTemplates

[![Build Status](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml?query=branch%3Amain)


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
```

## Benchmarks

In our two benchmarks at `benchmarks/suite.jl` we find that **StringTemplates** is:

- 1.7 - 2.5x faster than [Base string interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).
- 10.1 - 18.6x faster than [Mustache.jl](https://github.com/jverzani/Mustache.jl).

# StringTemplates

[![Build Status](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml?query=branch%3Amain)


<p align="center"><b>Speedy customizable string interpolation for Julia.</b></p>

## Usage

```julia
using StringTemplates

# Here's a template.  It uses Julia's interpolation syntax.
t = template"I'm going to interpolate two variables, x and y: $x and $y"


# `render` with object (uses getproperty) or keyword args to interpolate variables
render(t, (x=1, y=2))
render(t; x=1, y=2)


# Print to IO without allocating String
render(stdout, t; x=1, y=2)
```

## Customize Printing the Interpolated Values

- You can set any `print` function (default `Base.print`) that takes `(io::IO, x)` arguments.
- Use the `@template "..." print=Base.print` syntax.

```julia
using JSON3

# Here's a Javascript function that uses JSON arguments
t = @template "PlotlyJS.newPlot(\"my_id\", $data, $layout, $config)" print=JSON3.write

render(t, data=[(; y=1:2)], layout=(;), config=(; responsive=true))
# "PlotlyJS.newPlot(\"my_id\", [{\"y\":[1,2]}], {}, {\"responsive\":true})"
```


## Benchmarks

In our benchmark at `benchmarks/suite.jl` we find that **StringTemplates** is:

- 1.9x faster than [Base string interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).
- 13.6x faster than [Mustache.jl](https://github.com/jverzani/Mustache.jl).

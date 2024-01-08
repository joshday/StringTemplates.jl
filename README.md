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

## Custom Printers

- You can set a `printer` that determines how variables are interpolated into the template.
- Default is `Base.print`, but any function of `(io::IO, x)` will work.
- For example, if your template is based on JSON, you may want to use `JSON3.write` as your printer.  Notice how you wouldn't be able to create the result with `JSON3.write` directly:

```julia
using JSON3

# A Javascript function that uses JSON arguments
t = @template "PlotlyJS.newPlot(\"my_id\", $data, $layout, $config)" printer=JSON3.write

render(t, data=[(; y=1:2)], layout=(;), config=(; responsive=true))
# "PlotlyJS.newPlot(\"my_id\", "[{"y":[1,2]}]", "{}", "{"responsive":true}")"
```


## Benchmarks

In our benchmark at `benchmarks/suite.jl` we find that **StringInter** is:

- 10.26x faster than [Base string interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).
- 12.17x faster than [Mustache.jl](https://github.com/jverzani/Mustache.jl).

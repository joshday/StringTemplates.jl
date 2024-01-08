# StringInterp

[![Build Status](https://github.com/joshday/StringInterp.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/StringInterp.jl/actions/workflows/CI.yml?query=branch%3Amain)


<p align="center"><b>Speedy customizable string interpolation for Julia.</b></p>

## Usage

```julia
using StringInterp

# Here's a template.  It looks just like Julia's standard string interpolation syntax.
t = template"I'm going to interpolate two variables, x and y: $x and $y"

# The thing is that it's lazy.  The String isn't created until you `render` it.
# Variables are populated via `getproperty`
render(t, (x=1, y=2))

# Or you can pass variables as keyword args:
render(t; x=1, y=2)

# Maybe you don't even want to make the string.  You just want to write to an IO:
render(stdout, t, (x=1, y=2))  # equivalently render(stdout, t; x=1, y=2)
```

## Advanced Usage with Custom Printers

- You can provide any function to print the interpolated variables (default is `Base.print`).
- For example, if you're template is based on JSON, you may want to use `JSON3.write` as your printer:

```julia
using JSON3

t = @template "PlotlyJS.newPlot(\"my_id\", $data, $layout, $config)" printer=JSON3.write

render(t, data=[(; y=rand(2))], layout=(;), config=(; responsive=true))
```

## Benchmarks

In our benchmark at `benchmarks/suite.jl` we find that **StringInter** is:

- 10.26x faster than [Base string interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).
- 12.17x faster than [Mustache.jl](https://github.com/jverzani/Mustache.jl).

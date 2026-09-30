# StringTemplates

[![Build Status](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/joshday/StringTemplates.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/joshday/StringTemplates.jl)


<p align="center"><b>Speedy customizable string interpolation for Julia.</b></p>

## Features

- Performance (see `benchmarks/suite.jl` and its output `benchmarks/report.md`):
  - 1.0 - 5.1x faster than [Base string interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).
  - 50 - 203x faster than [Mustache.jl](https://github.com/jverzani/Mustache.jl) (v1.1).
- Julia's string interpolation syntax: `@template "Hello, $(name)!"`.
- Each variable is printed with its own function of `(io, value)`:
  - E.g. a JSON template can use `JSON3.write`.
  - E.g. an HTML template can use `(io, x) -> show(io, MIME("text/html"), x)`.
- Type checks on variables, before anything is written.
- Works with any object that has properties: `NamedTuple`s and structs.


## Usage

```julia
using StringTemplates, JSON3

# Variables use Julia's interpolation syntax: `$name`, `$(name::T)`, `$(name|f)`, or `$(name::T|f)`
t = @template "Hello, $(name::String)!"
# Hello, $(name::String|print)!

# `render` to any IO with any object that has the template's properties
render(stdout, t, (; name="World"))
# Hello, World!

# ...or get a String
render(t, (; name="World"))
# "Hello, World!"

# Structs work too.  For a `Dict{Symbol}`, use `NamedTuple(dict)`.
struct Person
    name::String
end
render(t, Person("Julia"))
# "Hello, Julia!"

# Each variable is printed with a function of `(io, value)`: its own with `$(name|f)`...
t2 = @template "PlotlyJS.newPlot(\"my_id\", $(data|JSON3.write), {}, {})"

render(t2, (; data=[(; y=1:2)]))
# "PlotlyJS.newPlot(\"my_id\", [{\"y\":[1,2]}], {}, {})"

# ...or the template's default (`print` unless given)
t3 = @template "PlotlyJS.newPlot(\"my_id\", $data, $layout)" JSON3.write

render(t3, (; data=[(; y=1:2)], layout=(; title="My Plot")))
# "PlotlyJS.newPlot(\"my_id\", [{\"y\":[1,2]}], {\"title\":\"My Plot\"})"

# Fill in some variables to get a new template
t4 = Template(@template("$greeting, $(name::String)!"), (; greeting="Hi"))
# Hi, $(name::String|print)!

render(t4, (; name="Julia"))
# "Hi, Julia!"

# Every variable is checked (present and the right type) before anything is written
render(stdout, t, (; name=1))
# ERROR: ArgumentError: name::String (got Int64).  Available properties: (:name,)

# Templates can also be built from strings and `Variable{name, T}(f)`s
Template(("Hello, ", Variable{:name, String}(print), "!"))
# Hello, $(name::String|print)!
```

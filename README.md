# StringTemplates

[![Build Status](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/StringTemplates.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/joshday/StringTemplates.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/joshday/StringTemplates.jl)


<p align="center"><b>Speedy customizable string interpolation for Julia.</b></p>

## Features

- Performance (see `benchmarks/suite.jl` and its output `benchmarks/report.md`):
  - 1.0 - 5.1x faster than [Base string interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation).
  - 50 - 203x faster than [Mustache.jl](https://github.com/jverzani/Mustache.jl) (v1.1).
- Use Julia's string interpolation syntax: `@template "Hello, $(name)!"`.
  - ...with optional type and print function `@template "x as JSON: $(x::AbstractDict|JSON.json)"`
- `render([io], ::Template, x)` uses `getproperty(x, variable)` to fill in the blanks.


## Example

```julia
using StringTemplates 

t = @template("""
    # How to use StringTemplates

    The `@template` macro creates a `Template` with variables defined by \$.

    You can define variables with optional type annotations and print function:

    - `\$var`: $var 
    - `\$typed_var`: $(typed_var::Int)
    - `\$var_with_print`: $(var_with_print | (io,x) -> print(io, uppercase(x)))

    You can fill in the blanks with any `x`'s properties using `render([io], t::Template, x)`
    """)

x = (;
    var = "I'm a variable!",
    typed_var = 10,
    var_with_print = "I will print in uppercase."
)

render(t, x)
```

### Result:

> # How to use StringTemplates
> 
> The `@template` macro creates a `Template` with variables defined by $.
> 
> You can define variables with optional type annotations and print function:
> 
> - `$var`: I'm a variable!
> - `$typed_var`: 10
> - `$var_with_print`: I WILL PRINT IN UPPERCASE.
> 
> You can fill in the blanks with any `x`'s properties using `render([io], t::Template, x)`

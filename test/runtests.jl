using StringTemplates
using Test

#-----------------------------------------------------------------------------# simple
t = @template "x: $x. y: $(y)."

@test render(t, (x=1, y=2)) == "x: 1. y: 2."
@test render(t; x=1, y=2) == "x: 1. y: 2."

#-----------------------------------------------------------------------------# printer
t2 = @template "x: $x. y: $y." (io, x) -> print(io, x^2)

@test render(t2; x=1, y=2) == "x: 1. y: 4."

#-----------------------------------------------------------------------------# string macro
t3 = template"x: $x, y:$y."

t3 = StringTemplates.printer(t3, (io, x) -> print(io, x^2))

@test render(t3; x=1, y=2) == "x: 1, y:4."

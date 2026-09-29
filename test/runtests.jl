using StringTemplates
using StringTemplates: Template, Property
using Test
using Aqua

#-----------------------------------------------------------------------------# simple
t = @template "x: $x. y: $(y)."

@test render(t, (x=1, y=2)) == "x: 1. y: 2."
@test render(t; x=1, y=2) == "x: 1. y: 2."
@test render(t, Dict(:x => 1, :y => 2)) == "x: 1. y: 2."
@test sprint(render, t, (x=1, y=2)) == "x: 1. y: 2."
@test render(@template("no properties")) == "no properties"

#-----------------------------------------------------------------------------# printer
t2 = @template "x: $x. y: $y." (io, x) -> print(io, x^2)

@test render(t2; x=1, y=2) == "x: 1. y: 4."

#-----------------------------------------------------------------------------# string macro
t3 = template"x: $x, y:$y."

@test render(t3; x=1, y=2) == "x: 1, y:2."

#-----------------------------------------------------------------------------# Property / Template constructors
@test render(Template(["a ", Property(:x), " b"]); x=1) == "a 1 b"
@test render(Template(; parts=("a ", Property(:x, String)), print=(io, x) -> print(io, uppercase(x))); x="hi") == "a HI"
@test repr(@template "x: $x. y: $(y::Int).") == "x: \$x. y: \$(y::$Int)."

#-----------------------------------------------------------------------------# typed properties
t4 = @template "x: $(x::Int). y: $(y::AbstractString)."

@test render(t4; x=1, y="two") == "x: 1. y: two."
@test render(t4, Dict{Symbol, Any}(:x => 1, :y => "two")) == "x: 1. y: two."
@test_throws TypeError render(t4; x=1.0, y="two")
# NamedTuple with abstract field types: checked per value
@test render(t4, NamedTuple{(:x, :y), Tuple{Any, Any}}((1, "two"))) == "x: 1. y: two."
@test_throws TypeError render(t4, NamedTuple{(:x, :y), Tuple{Any, Any}}((1, 2)))
@test StringTemplates.check((; x=1, y="two"), t4)
@test !StringTemplates.check((; x=1, y=2), t4)
@test !StringTemplates.check((; x=1), t4)

#-----------------------------------------------------------------------------# field order / extra fields
@test render(t, (y="b", x="a")) == "x: a. y: b."
@test render(t, (z=0, x=1, y=2)) == "x: 1. y: 2."

#-----------------------------------------------------------------------------# errors
@test_throws ArgumentError render(t; x=1)
let io = IOBuffer()
    @test_throws ArgumentError render(io, t, (; x=1))
    @test position(io) == 0  # nothing written before the error
end
@test_throws Exception macroexpand(@__MODULE__, :(@template "a $(x.y)"))

#-----------------------------------------------------------------------------# performance
long = @eval @template $(Expr(:string, map(i -> iseven(i) ? Symbol(:x, i) : "-", 1:61)...))
long_obj = (; map(i -> Symbol(:x, i) => string(i), 2:2:61)...)

@test render(long, long_obj) == join(map(i -> iseven(i) ? string(i) : "-", 1:61))
@inferred render(long, long_obj)
@inferred render(t4, (; x=1, y="two"))
let io = IOBuffer(; sizehint=1000)
    render(io, long, long_obj)
    @test @allocated(render(io, long, long_obj)) == 0
end

#-----------------------------------------------------------------------------# Aqua
Aqua.test_all(StringTemplates; deps_compat=false)

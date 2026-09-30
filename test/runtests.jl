using StringTemplates
using StringTemplates: check, name, type
using Test
using Aqua

V(n, T=Any, f=print) = Variable{n, T}(f)
str(t, x) = sprint(io -> render(io, t, x))  # IO method; `render(t, x)` is tested against it below

t = Template(("x: ", V(:x), ". y: ", V(:y), "."))

#-----------------------------------------------------------------------------# render
@test str(t, (x=1, y=2)) == "x: 1. y: 2."
@test str(t, (y="b", x="a")) == "x: a. y: b."  # field order doesn't matter
@test str(t, (z=0, x=1, y=2)) == "x: 1. y: 2."  # extra fields are ignored
struct XY
    x::Int
    y::String
end
@test str(t, XY(1, "two")) == "x: 1. y: two."  # any object with properties
@test str(Template(("no variables",)), (;)) == "no variables"
@test str(Template(()), (;)) == ""
@test str(Template(("a ", V(:x), " again ", V(:x))), (; x=1)) == "a 1 again 1"

#-----------------------------------------------------------------------------# Variable
@test name(V(:x, Int)) === :x
@test Variable{:x, Int}(print) === Variable{:x, Int, typeof(print)}(print)
@test type(V(:x, Int)) === Int

brackets(io, x) = print(io, '<', x, '>')
@test str(Template(("a: ", V(:a, Any, brackets))), (; a=1)) == "a: <1>"
let prefix = "~"  # closure that captures data
    @test str(Template((V(:a, Any, (io, x) -> print(io, prefix, x)),)), (; a=1)) == "~1"
end

#-----------------------------------------------------------------------------# typed variables / check
t2 = Template(("a: ", V(:a), ", b: ", V(:b, Int), ", c: ", V(:c), ", d: ", V(:d, AbstractString)))

@test str(t2, (; a=1, b=2, c=3, d="4")) == "a: 1, b: 2, c: 3, d: 4"
@test check(t2, (; a=1, b=2, c=3, d="4")) === nothing
@test check(t2, NamedTuple{(:a, :b, :c, :d), NTuple{4, Any}}((1, 2, 3, "4"))) === nothing  # checked per value
@test_throws ArgumentError check(t2, (; a=1, b=2.0, c=3, d="4"))
@test_throws ArgumentError check(t2, (; a=1, b=2, c=3))

errmsg(t, x) = try check(t, x); "no error" catch e; String(e.msg) end
@test errmsg(t2, (; b="2", d=4)) == "a not found, b::$Int (got String), c not found, d::AbstractString (got $Int).  Available properties: (:b, :d)"
@test errmsg(Template((V(:a), V(:a))), (;)) == "a not found.  Available properties: ()"  # each problem reported once

let io = IOBuffer()
    @test_throws ArgumentError render(io, t2, (; a=1))
    @test position(io) == 0  # nothing written before the error
end
@test_throws ArgumentError render(t2, (; a=1))  # checked before the buffer is sized

#-----------------------------------------------------------------------------# render(t, x)::String
@test render(t, (x=1, y=2)) == str(t, (x=1, y=2))
@test render(t2, (; a=1, b=2, c=3, d="4")) == "a: 1, b: 2, c: 3, d: 4"
@test render(t, XY(1, "two")) == "x: 1. y: two."
@test render(Template(()), (;)) == ""

#-----------------------------------------------------------------------------# partial fill
let tx = Template(t, (; x=1))
    @test tx.parts == ("x: 1. y: ", V(:y), ".")
    @test render(tx, (; y=2)) == render(t, (x=1, y=2))
end
@test Template(t, (; z=0)).parts == t.parts  # nothing to fill in
@test Template(t, (x=1, y=2)).parts == ("x: 1. y: 2.",)
@test Template(t, XY(1, "two")).parts == ("x: 1. y: two.",)
@test Template(Template((V(:x), V(:y))), (; x="a")).parts == ("a", V(:y))
@test Template(Template(("a: ", V(:a, Any, brackets))), (; a=1)).parts == ("a: <1>",)  # the variable's print is used
@test Template(t2, (; b=2)).parts == ("a: ", V(:a), ", b: 2, c: ", V(:c), ", d: ", V(:d, AbstractString))
@test_throws ArgumentError Template(t2, (; b="2"))  # filled-in values are type-checked
@test (try Template(t2, (; b="2")) catch e; String(e.msg) end) == "b::$Int (got String).  Available properties: (:b,)"
let a = (; a=1, c=3), b = (; b=2, d="4")
    @test render(Template(t2, a), b) == render(t2, merge(a, b))
    @test render(Template(Template(t2, a), b), (;)) == render(t2, merge(a, b))
end

#-----------------------------------------------------------------------------# @template
@test (@template "x: $x. y: $(y).").parts == t.parts
@test (@template "no variables").parts == ("no variables",)
@test (@template "a: $(a::Int), b: $(b|brackets), c: $(c::String|brackets)").parts ==
    ("a: ", V(:a, Int), ", b: ", V(:b, Any, brackets), ", c: ", V(:c, String, brackets))
@test render(@template("$a $(b|brackets)", (io, x) -> print(io, -x)), (; a=1, b=2)) == "-1 <2>"  # default print
@test render(@template("$(x|((io, v) -> print(io, v, v)))"), (; x=1)) == "11"  # anonymous functions need parentheses
let t = @template "$a $b" (io, x) -> print(io, x)
    @test t.parts[1].print === t.parts[3].print  # the default print is evaluated once
end
let prefix = "~"
    @test render(@template("$(a|((io, x) -> print(io, prefix, x)))"), (; a=1)) == "~1"
end
make() = @template "a: $(a::Int|brackets)"
@inferred make()  # type-stable construction
@test_throws Exception macroexpand(@__MODULE__, :(@template x))
@test_throws Exception macroexpand(@__MODULE__, :(@template "a $(x.y)"))
@test_throws Exception macroexpand(@__MODULE__, :(@template "a $(x|f|g)"))
@test_throws Exception macroexpand(@__MODULE__, :(@template "a $(x.y::Int)"))

#-----------------------------------------------------------------------------# show
@test sprint(show, V(:x, Int)) == "\$(x::$Int|print)"
@test sprint(show, t) == "x: \$(x::Any|print). y: \$(y::Any|print)."

#-----------------------------------------------------------------------------# performance
long = Template(Tuple(map(i -> iseven(i) ? V(Symbol(:x, i)) : "-", 1:61)))  # > 32 parts
long_obj = (; map(i -> Symbol(:x, i) => string(i), 2:2:61)...)

@test str(long, long_obj) == join(map(i -> iseven(i) ? string(i) : "-", 1:61))
@test render(long, long_obj) == str(long, long_obj)
@inferred check(long, long_obj)
@inferred render(IOBuffer(), long, long_obj)
@inferred render(long, long_obj)
let n = StringTemplates.unrolled_sum(p -> StringTemplates.nbytes(StringTemplates.value(p, long_obj)), long.parts)
    @test n == sizeof(render(long, long_obj))  # exact for string values
end
let io = IOBuffer(; sizehint=1000)
    render(io, long, long_obj)
    @test @allocated(check(long, long_obj)) == 0
    @test @allocated(render(io, long, long_obj)) == 0
end

#-----------------------------------------------------------------------------# Aqua
Aqua.test_all(StringTemplates; deps_compat=false)

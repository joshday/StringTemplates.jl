module StringTemplates

export Template, Variable, render, @template

using StyledStrings

#------------------------------------------------------------------------------# Variable
struct Variable{name, type, F}
    print::F
end
Variable{name, T}(f) where {name, T} = Variable{name, T, typeof(f)}(f)
name(::Variable{n}) where {n} = n
type(::Variable{n, T}) where {n, T} = T

function Base.show(io::IO, v::Variable{name, type, F}) where {name, type, F}
    print(io, styled"{bright_cyan:\$($name::$type|$(v.print))}")
end

#------------------------------------------------------------------------------# Template
struct Template{T <: Tuple}
    parts::T
end

Base.show(io::IO, t::Template) = foreach(p -> print(io, p isa String ? styled"{gray:$p}" : p), t.parts)

# `foreach` over a tuple, unrolled for any length (Base only unrolls tuples up to 32 elements)
@generated function unrolled_foreach(f, t::Tuple)
    quote
        Base.Cartesian.@nexprs $(fieldcount(t)) i -> f(t[i])
        nothing
    end
end

# `sum(f, t)`, unrolled for any length
@generated unrolled_sum(f, t::Tuple) = foldl((a, i) -> :($a + f(t[$i])), 1:fieldcount(t); init=0)

#------------------------------------------------------------------------------# check
valid(::AbstractString, x) = true
valid(v::Variable, x) = hasproperty(x, name(v)) && getproperty(x, name(v)) isa type(v)

# Throws if any variable is missing or has the wrong type.  Allocates nothing unless it throws.
check(t::Template, x) = unrolled_foreach(p -> valid(p, x) || throw_invalid(t, x), t.parts)

@noinline function throw_invalid(t::Template, x)
    msg = join(map(v -> problem(v, x), unique(filter(p -> !valid(p, x), collect(t.parts)))), ", ")
    throw(ArgumentError(styled"$msg.  Available properties: $(propertynames(x))"))
end

problem(v::Variable, x) = hasproperty(x, name(v)) ?
    styled"{red:$(name(v))::$(type(v))} (got $(typeof(getproperty(x, name(v)))))" :
    styled"{red:$(name(v))} not found"

#------------------------------------------------------------------------------# render
value(s::AbstractString, x) = s
value(v::Variable, x) = getproperty(x, name(v))

render(io::IO, s::AbstractString, x) = print(io, s)
render(io::IO, v::Variable, x) = v.print(io, value(v, x))

# Every variable is checked before anything is written
function render(io::IO, t::Template, x)
    check(t, x)
    unrolled_foreach(p -> render(io, p, x), t.parts)
end

# Estimated bytes written for a value (used to size the output buffer)
nbytes(s::AbstractString) = sizeof(s)
nbytes(x) = 8

function render(t::Template, x)
    check(t, x)
    io = IOBuffer(; sizehint=unrolled_sum(p -> nbytes(value(p, x)), t.parts))
    unrolled_foreach(p -> render(io, p, x), t.parts)
    return String(take!(io))
end

#------------------------------------------------------------------------------# partial fill
# Does `x` fill in part `p`?
fills(x, p) = p isa Variable && hasproperty(x, name(p))

# A new template with the variables found in `x` rendered into strings and the rest kept.
# Satisfies `render(Template(t, a), b) == render(t, merge(a, b))`.
function Template(t::Template, x)
    check(Template(filter(p -> fills(x, p), t.parts)), x)  # type-check the values being filled in
    return Template(merge_strings(map(p -> fills(x, p) ? sprint(render, p, x) : p, t.parts)))
end

# Join adjacent strings, e.g. ("a", "b", v) → ("ab", v)
function merge_strings(parts::Tuple)
    out = Any[]
    foreach(parts) do p
        p isa AbstractString && !isempty(out) && last(out) isa AbstractString ? (out[end] *= p) : push!(out, p)
    end
    return Tuple(out)
end

#------------------------------------------------------------------------------# @template
# `@template "a $x $(y::T) $(z|f) $(w::T|f)" [print]`: `f(io, value)` prints a variable (default `print`)
macro template(ex, print=:(Base.print))
    parts = ex isa String ? (ex,) : Meta.isexpr(ex, :string) ? ex.args :
        throw(ArgumentError("@template expects a string literal.  Got: `$ex`"))
    p = gensym(:print)  # evaluated once, for the variables without their own `|f`
    return esc(:(let $p = $print; $Template(($(map(x -> template_part(x, p), parts)...),)) end))
end

template_part(s::String, print) = s
function template_part(x, print)
    # `::` binds tighter than `|`, so `name::T|f` parses as `(name::T) | f`
    (ex, f) = Meta.isexpr(x, :call, 3) && x.args[1] === :| ? x.args[2:3] : (x, print)
    (name, T) = ex isa Symbol ? (ex, Any) : Meta.isexpr(ex, :(::), 2) ? ex.args : (nothing, nothing)
    name isa Symbol || throw(ArgumentError("Only `\$name`, `\$(name::T)`, `\$(name|f)`, and `\$(name::T|f)` are supported.  Got: `\$($x)`"))
    return :($Variable{$(QuoteNode(name)), $T}($f))
end

end  # module

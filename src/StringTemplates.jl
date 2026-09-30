module StringTemplates

export Template, Variable, render, @template

using StyledStrings

#------------------------------------------------------------------------------# Variable
struct Variable{name, T, F}
    print::F
end
name(::Variable{N,T,F}) where {N,T,F} = N
type(::Variable{N,T,F}) where {N,T,F} = T

Variable{name, T}(f) where {name, T} = Variable{name, T, typeof(f)}(f)

function Base.show(io::IO, v::Variable{name, T, F}) where {name, T, F}
    s = string(name, T === Any ? "" : "::$T", v.print === print ? "" : "|$(v.print)")
    print(io, styled"{bright_cyan:\$($s)}")
end

#------------------------------------------------------------------------------# Template
struct Template{T <: Tuple}
    parts::T
end

Base.show(io::IO, t::Template) = foreach(p -> print(io, p isa AbstractString ? styled"{gray:$p}" : p), t.parts)

# `map` over a tuple, unrolled for any length (Base only unrolls tuples up to 32 elements)
@generated tmap(f, t::Tuple) = :(($(map(i -> :(f(t[$i])), 1:fieldcount(t))...),))

#------------------------------------------------------------------------------# check
valid(::AbstractString, x) = true
valid(::Variable{name,T,F}, x) where {name,T,F} = hasproperty(x, name) && getproperty(x, name) isa T

# Throws if any variable is missing or has the wrong type.  Allocates nothing unless it throws.
check(t::Template, x) = all(tmap(p -> valid(p, x), t.parts)) || throw_invalid(t, x)

@noinline function throw_invalid(t::Template, x)
    idx = findall(tmap(p -> !valid(p, x), t.parts))
    msg = join(unique(problem.(t.parts[idx], Ref(x))), ", ")
    throw(ArgumentError(styled"$msg.  Available properties: {bright_yellow:$(propertynames(x))}"))
end

problem(v::Variable{name,T,F}, x) where {name,T,F} = hasproperty(x, name) ?
    styled"{bright_red:$(name)::$(T)} (got $(typeof(getproperty(x, name))))" :
    styled"{bright_red:$(name)} not found"

#------------------------------------------------------------------------------# render
value(s::AbstractString, x) = s
value(::Variable{name,T,F}, x) where {name,T,F} = getproperty(x, name)

render(io::IO, s::AbstractString, x) = print(io, s)
render(io::IO, v::Variable, x) = v.print(io, value(v, x))

function render(io::IO, t::Template, x)
    check(t, x)
    tmap(p -> render(io, p, x), t.parts)
    return nothing
end

# Estimated bytes for IOBuffer sizehint
nbytes(s::AbstractString) = sizeof(s)
nbytes(x) = 8

function render(t::Template, x)
    check(t, x)
    io = IOBuffer(; sizehint=sum(tmap(p -> nbytes(value(p, x)), t.parts); init=0))
    render(io, t, x)
    return String(take!(io))
end

#------------------------------------------------------------------------------# partial fill
# Does `x` fill in part `p`?
fills(x, p) = p isa Variable && hasproperty(x, name(p))

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

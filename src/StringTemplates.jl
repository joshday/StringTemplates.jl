module StringTemplates

using StyledStrings: @styled_str

export @template, @template_str, render

#------------------------------------------------------------------------------# Property
# `name` and `T` are type parameters so `render` can resolve lookups (and printing) at compile time
struct Property{name, T} end
Property(name::Symbol, T::Type=Any) = Property{name, T}()

Base.nameof(::Property{name}) where {name} = name

function Base.show(io::IO, ::Property{name, T}) where {name, T}
    T === Any ? print(io, '$', name) : print(io, "\$(", name, "::", T, ')')
end

#------------------------------------------------------------------------------# Template
@kwdef struct Template{S <: Tuple{Vararg{Union{AbstractString, Property}}}, P <: Base.Callable}
    parts::S = ()
    print::P = Base.print
end
Template(parts::AbstractVector, print=Base.print) = Template(Tuple(parts), print)

function Base.show(io::IO, t::Template)
    foreach(t.parts) do x
        print(io, styled"{$(x isa AbstractString ? :gray : :bright_green):$x}")
    end
end

props(t::Template) = filter(x -> x isa Property, t.parts)

check(obj, t::Template) = all(p -> valid(obj, p), props(t))

#------------------------------------------------------------------------------# lookup
struct NotFound end

lookup(obj::NamedTuple, name::Symbol) = haskey(obj, name) ? getfield(obj, name) : NotFound()
lookup(obj::AbstractDict, name::Symbol) = get(obj, name, NotFound())
lookup(obj, name::Symbol) = haskey(obj, name) ? obj[name] : NotFound()

function valid(obj, ::Property{name, T}) where {name, T}
    x = lookup(obj, name)
    return !(x isa NotFound) && x isa T
end

@noinline function throw_missing(t::Template, obj)
    names = unique(map(nameof, filter(p -> lookup(obj, nameof(p)) isa NotFound, props(t))))
    throw(ArgumentError("Missing keys: $(join(names, ", "))"))
end

# What gets printed for each part.  Throws if a key is missing or a value has the wrong type.
value(t::Template, obj, s::AbstractString) = s
function value(t::Template, obj, ::Property{name, T}) where {name, T}
    x = lookup(obj, name)
    x isa NotFound && throw_missing(t, obj)
    x isa T || throw(TypeError(:render, "property `$name`", T, x))
    return x
end

#------------------------------------------------------------------------------# render
estimate_size(s::AbstractString) = sizeof(s)
estimate_size(x) = 8

# Unrolled so every part is type-stable (`map`/`foreach` on a Tuple are only unrolled up to 32 elements).
# All values are looked up before anything is written.  The body only depends on the number of parts.
function render_body(n::Int; tostring::Bool)
    x = map(i -> Symbol(:x, i), 1:n)
    lookups = map(i -> :($(x[i]) = value(t, obj, t.parts[$i])), 1:n)
    prints = map(i -> :(t.parts[$i] isa Property ? t.print(io, $(x[i])) : print(io, $(x[i]))), 1:n)
    tostring || return Expr(:block, lookups..., prints..., nothing)
    # binary `+` chain: a long varargs `+` call isn't specialized
    sizehint = foldl((a, b) -> :($a + $b), map(i -> :(estimate_size($(x[i]))), 1:n); init=0)
    return Expr(:block, lookups..., :(io = IOBuffer(; sizehint=$sizehint)), prints..., :(String(take!(io))))
end

@generated render(io::IO, t::Template{S}, obj) where {S} = render_body(fieldcount(S); tostring=false)
render(io::IO, t::Template; kw...) = render(io, t, values(kw))

@generated render(t::Template{S}, obj) where {S} = render_body(fieldcount(S); tostring=true)
render(t::Template; kw...) = render(t, values(kw))

#------------------------------------------------------------------------------# @template
macro template(ex, print=:(Base.print))
    template_expr(ex, print)
end

macro template_str(s)
    template_expr(Meta.parse(string("\"\"\"", s, "\"\"\"")), :(Base.print))
end

function template_expr(ex, print)
    parts = ex isa AbstractString ? [ex] :
        Meta.isexpr(ex, :string) ? ex.args :
        throw(ArgumentError("@template expects a string literal.  Got: `$ex`"))
    return esc(:($Template(($(map(template_part, parts)...),), $print)))
end

template_part(x::AbstractString) = x
template_part(x::Symbol) = :($Property{$(QuoteNode(x)), Any}())
function template_part(x)
    Meta.isexpr(x, :(::), 2) && x.args[1] isa Symbol ||
        throw(ArgumentError("Only `\$name` and `\$(name::T)` interpolation is supported.  Got: `\$($x)`"))
    return :($Property{$(QuoteNode(x.args[1])), $(x.args[2])}())
end

#------------------------------------------------------------------------------# precompile
let t = @template "x = $x"
    render(t; x=1)
    render(t, Dict(:x => "1"))
    render(IOBuffer(), t; x=1)
end

end  # module

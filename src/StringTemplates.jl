module StringTemplates

using StyledStrings: @styled_str

export @template, @template_str, render

#-----------------------------------------------------------------------------# Template
struct Template{P <: Base.Callable}
    parts::Vector{Union{String, Symbol}}
    print::P
end
function Base.show(io::IO, t::Template)
    foreach(t.parts) do x
        print(io, styled"{$(x isa String ? :gray : :bright_green):$x}")
    end
end

props(t::Template) = filter(x -> x isa Symbol, t.parts)

check(obj, t::Template) = all(x -> haskey(obj, x), props(t))

function render(io::IO, t::Template, obj)
    for x in t.parts
        if x isa Symbol
            haskey(obj, x) || throw(ArgumentError("Missing keys: $(join(setdiff(props(t), keys(obj)), ", "))"))
            t.print(io, obj[x])
        else
            print(io, x)
        end
    end
end
render(io::IO, t::Template; @nospecialize(kw...)) = render(io, t, NamedTuple(kw))

render(t::Template, obj) = sprint(render, t, obj)
render(t::Template; @nospecialize(kw...)) = render(t, NamedTuple(kw))

#-----------------------------------------------------------------------------# @template
macro template(e, print=:(Base.print))
    if e isa String
        return esc(:(StringTemplates.Template(Union{String,Symbol}[$e], $print)))
    else
        parts = Vector{Union{String, Symbol}}(e.args)
        return esc(:(StringTemplates.Template($parts, $print)))
    end
end

macro template_str(e)
    arg = Meta.parse(string("\"\"\"", e, "\"\"\""))
    esc(:(StringTemplates.@template $arg))
end


end  # module

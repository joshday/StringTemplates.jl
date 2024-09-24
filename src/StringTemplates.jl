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

change_print(t::Template, print) = Template(t.parts, print)

check(obj, t::Template) = all(x -> hasproperty(obj, x), props(t))

function render(io::IO, t::Template, obj)
    foreach(x -> x isa Symbol ? t.print(io, obj[x]) : print(io, x), t.parts)
end
render(t::Template, obj) = sprint(render, t, obj)
render(io::IO, t::Template; @nospecialize(kw...)) = render(io, t, NamedTuple(kw))
render(t::Template; @nospecialize(kw...)) = render(t, NamedTuple(kw))

#-----------------------------------------------------------------------------# @template
macro template(e, print=:(Base.print))
    e isa String && return esc(:(StringTemplates.Template(Union{String,Symbol}[$e], $print)))
    parts = Vector{Union{String, Symbol}}(e.args)
    esc(:(StringTemplates.Template($parts, $print)))
end

macro template_str(e)
    arg = Meta.parse(string("\"\"\"", e, "\"\"\""))
    esc(:(StringTemplates.@template $arg))
end


end  # module

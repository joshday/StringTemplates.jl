module StringInterp

export @template, @template_str, render

#-----------------------------------------------------------------------------# Template
struct Template{P}
    parts::Vector{Union{String, Symbol}}
    printer::P
end
props(t::Template) = filter(x -> x isa Symbol, t.parts)

printer(t::Template, printer) = Template(t.parts, printer)

#-----------------------------------------------------------------------------# @template
macro template(e, printer=:print)
    e isa String && return esc(:(StringInterp.Template(Union{String,Symbol}[$e], $printer)))
    parts = Vector{Union{String,Symbol}}(e.args)
    esc(:(StringInterp.Template($parts, $printer)))
end

macro template_str(e)
    arg = Meta.parse(string('"', e, '"'))
    esc(:(StringInterp.@template $arg))
end

function Base.show(io::IO, t::Template)
    printstyled(io, '"'; color=:light_black)
    foreach(x -> printstyled(io, x; color = x isa Symbol ? :light_cyan : :light_black), t.parts)
    printstyled(io, '"'; color=:light_black)
    printstyled(io, "  (printer: $(t.printer))"; color = :light_green)
end

check(obj, t::Template) = all(x -> hasproperty(obj, x), props(t))

#-----------------------------------------------------------------------------# render
function render(io::IO, t::Template, obj)
    foreach(x -> x isa Symbol ? t.printer(io, getproperty(obj, x)) : print(io, x), t.parts)
end
render(t::Template, obj) = sprint(render, t, obj)
render(io::IO, t::Template; @nospecialize(kw...)) = render(io, t, NamedTuple(kw))
render(t::Template; @nospecialize(kw...)) = render(t, NamedTuple(kw))




end  # module

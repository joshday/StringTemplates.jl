import Pkg

Pkg.activate(@__DIR__)

using StringTemplates, Mustache, BenchmarkTools, Dates, InteractiveUtils

#==============================================================================#
# Data
#==============================================================================#
obj_int = (; (Symbol(letter) => i for (i, letter) in enumerate('a':'z'))...)
obj_str = (; (Symbol(letter) => letter ^ i for (i, letter) in enumerate('a':'z'))...)

#==============================================================================#
# Helpers
#==============================================================================#
function row(st, mu, ba)
    m_st = minimum(st)
    m_mu = minimum(mu)
    m_ba = minimum(ba)
    r_mu = ratio(m_mu, m_st)
    r_ba = ratio(m_ba, m_st)
    time_st = BenchmarkTools.prettytime(m_st.time)
    time_mu = BenchmarkTools.prettytime(m_mu.time)
    time_ba = BenchmarkTools.prettytime(m_ba.time)
    mem_st = "$(BenchmarkTools.prettymemory(m_st.memory)) ($(m_st.allocs))"
    mem_mu = "$(BenchmarkTools.prettymemory(m_mu.memory)) ($(m_mu.allocs))"
    mem_ba = "$(BenchmarkTools.prettymemory(m_ba.memory)) ($(m_ba.allocs))"
    vs_mu_time = "$(round(r_mu.time, digits=1))x"
    vs_ba_time = "$(round(r_ba.time, digits=1))x"
    r_mu_mem = m_st.memory == 0 ? 0.0 : m_st.memory / m_mu.memory
    r_ba_mem = m_st.memory == 0 ? 0.0 : m_st.memory / m_ba.memory
    vs_mu_mem = "$(round(r_mu_mem, digits=1))x"
    vs_ba_mem = "$(round(r_ba_mem, digits=1))x"
    return (; time_st, time_mu, time_ba, mem_st, mem_mu, mem_ba, vs_mu_time, vs_ba_time, vs_mu_mem, vs_ba_mem)
end

#==============================================================================#
# Benchmark 1: Small template (2 variables, string return)
#==============================================================================#
@info "Benchmark 1: Small template (2 vars, string return)"

t_small = template"x: $a, y: $b."
m_small = Mustache.mt"x: {{a}}, y: {{b}}."
d_small = Dict(:a => 1, :b => 2)

st1 = @benchmark StringTemplates.render($t_small, $obj_int)
mu1 = @benchmark Mustache.render($m_small, $d_small)
ba1 = @benchmark string("x: ", $(obj_int.a), ", y: ", $(obj_int.b), ".")

#==============================================================================#
# Benchmark 2: Mostly-static template (few vars, lots of text, string return)
#==============================================================================#
@info "Benchmark 2: Mostly-static template (2 vars in lots of text, string return)"

static_text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
st_mostly_static = StringTemplates.Template(Union{String,Symbol}[static_text, " Name: ", :name, ". ", static_text, " Age: ", :age, ". ", static_text], print)
mu_mostly_static = Mustache.mt"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.  Name: {{name}}. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.  Age: {{age}}. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "

d_mostly_static = Dict(:name => "Alice", :age => 30)
obj_mostly_static = (; name="Alice", age=30)

st2 = @benchmark StringTemplates.render($st_mostly_static, $obj_mostly_static)
mu2 = @benchmark Mustache.render($mu_mostly_static, $d_mostly_static)
ba2 = @benchmark string($static_text, " Name: ", "Alice", ". ", $static_text, " Age: ", 30, ". ", $static_text)

#==============================================================================#
# Benchmark 3: Many variables, int values (string return)
#==============================================================================#
@info "Benchmark 3: Many variables, int values (string return)"

t_many = template"Here is a: $a. Here is b: $b. Here is c: $c. Here is d: $d. Here is e: $e. Here is f: $f. Here is g: $g. Here is h: $h. Here is i: $i. Here is j: $j. Here is k: $k. Here is l: $l. Here is m: $m. Here is n: $n. Here is o: $o. Here is p: $p. Here is q: $q. Here is r: $r. Here is s: $s. Here is t: $t. Here is u: $u. Here is v: $v. Here is w: $w. Here is x: $x. Here is y: $y. Here is z: $z."
m_many = Mustache.mt"Here is a: {{a}}. Here is b: {{b}}. Here is c: {{c}}. Here is d: {{d}}. Here is e: {{e}}. Here is f: {{f}}. Here is g: {{g}}. Here is h: {{h}}. Here is i: {{i}}. Here is j: {{j}}. Here is k: {{k}}. Here is l: {{l}}. Here is m: {{m}}. Here is n: {{n}}. Here is o: {{o}}. Here is p: {{p}}. Here is q: {{q}}. Here is r: {{r}}. Here is s: {{s}}. Here is t: {{t}}. Here is u: {{u}}. Here is v: {{v}}. Here is w: {{w}}. Here is x: {{x}}. Here is y: {{y}}. Here is z: {{z}}."

d_int = Dict(pairs(obj_int)...)

st3 = @benchmark StringTemplates.render($t_many, $obj_int)
mu3 = @benchmark Mustache.render($m_many, $d_int)
ba3 = @benchmark string("Here is a: ", $(obj_int.a), ". Here is b: ", $(obj_int.b), ". Here is c: ", $(obj_int.c), ". Here is d: ", $(obj_int.d), ". Here is e: ", $(obj_int.e), ". Here is f: ", $(obj_int.f), ". Here is g: ", $(obj_int.g), ". Here is h: ", $(obj_int.h), ". Here is i: ", $(obj_int.i), ". Here is j: ", $(obj_int.j), ". Here is k: ", $(obj_int.k), ". Here is l: ", $(obj_int.l), ". Here is m: ", $(obj_int.m), ". Here is n: ", $(obj_int.n), ". Here is o: ", $(obj_int.o), ". Here is p: ", $(obj_int.p), ". Here is q: ", $(obj_int.q), ". Here is r: ", $(obj_int.r), ". Here is s: ", $(obj_int.s), ". Here is t: ", $(obj_int.t), ". Here is u: ", $(obj_int.u), ". Here is v: ", $(obj_int.v), ". Here is w: ", $(obj_int.w), ". Here is x: ", $(obj_int.x), ". Here is y: ", $(obj_int.y), ". Here is z: ", $(obj_int.z), ".")

#==============================================================================#
# Benchmark 4: Many variables, string values (string return)
#==============================================================================#
@info "Benchmark 4: Many variables, string values (string return)"

d_str = Dict(pairs(obj_str)...)

st4 = @benchmark StringTemplates.render($t_many, $obj_str)
mu4 = @benchmark Mustache.render($m_many, $d_str)
ba4 = @benchmark string("Here is a: ", $(obj_str.a), ". Here is b: ", $(obj_str.b), ". Here is c: ", $(obj_str.c), ". Here is d: ", $(obj_str.d), ". Here is e: ", $(obj_str.e), ". Here is f: ", $(obj_str.f), ". Here is g: ", $(obj_str.g), ". Here is h: ", $(obj_str.h), ". Here is i: ", $(obj_str.i), ". Here is j: ", $(obj_str.j), ". Here is k: ", $(obj_str.k), ". Here is l: ", $(obj_str.l), ". Here is m: ", $(obj_str.m), ". Here is n: ", $(obj_str.n), ". Here is o: ", $(obj_str.o), ". Here is p: ", $(obj_str.p), ". Here is q: ", $(obj_str.q), ". Here is r: ", $(obj_str.r), ". Here is s: ", $(obj_str.s), ". Here is t: ", $(obj_str.t), ". Here is u: ", $(obj_str.u), ". Here is v: ", $(obj_str.v), ". Here is w: ", $(obj_str.w), ". Here is x: ", $(obj_str.x), ". Here is y: ", $(obj_str.y), ". Here is z: ", $(obj_str.z), ".")

#==============================================================================#
# Benchmark 5: Many variables, int values (IO write)
#==============================================================================#
@info "Benchmark 5: Many variables, int values (IO write)"

st5 = @benchmark StringTemplates.render(io, $t_many, $obj_int) setup=(io = IOBuffer())
mu5 = @benchmark Mustache.render(io, $m_many, $d_int) setup=(io = IOBuffer())
ba5 = @benchmark print(io, "Here is a: ", $(obj_int.a), ". Here is b: ", $(obj_int.b), ". Here is c: ", $(obj_int.c), ". Here is d: ", $(obj_int.d), ". Here is e: ", $(obj_int.e), ". Here is f: ", $(obj_int.f), ". Here is g: ", $(obj_int.g), ". Here is h: ", $(obj_int.h), ". Here is i: ", $(obj_int.i), ". Here is j: ", $(obj_int.j), ". Here is k: ", $(obj_int.k), ". Here is l: ", $(obj_int.l), ". Here is m: ", $(obj_int.m), ". Here is n: ", $(obj_int.n), ". Here is o: ", $(obj_int.o), ". Here is p: ", $(obj_int.p), ". Here is q: ", $(obj_int.q), ". Here is r: ", $(obj_int.r), ". Here is s: ", $(obj_int.s), ". Here is t: ", $(obj_int.t), ". Here is u: ", $(obj_int.u), ". Here is v: ", $(obj_int.v), ". Here is w: ", $(obj_int.w), ". Here is x: ", $(obj_int.x), ". Here is y: ", $(obj_int.y), ". Here is z: ", $(obj_int.z), ".") setup=(io = IOBuffer())

#==============================================================================#
# Benchmark 6: Many variables, string values (IO write)
#==============================================================================#
@info "Benchmark 6: Many variables, string values (IO write)"

st6 = @benchmark StringTemplates.render(io, $t_many, $obj_str) setup=(io = IOBuffer())
mu6 = @benchmark Mustache.render(io, $m_many, $d_str) setup=(io = IOBuffer())
ba6 = @benchmark print(io, "Here is a: ", $(obj_str.a), ". Here is b: ", $(obj_str.b), ". Here is c: ", $(obj_str.c), ". Here is d: ", $(obj_str.d), ". Here is e: ", $(obj_str.e), ". Here is f: ", $(obj_str.f), ". Here is g: ", $(obj_str.g), ". Here is h: ", $(obj_str.h), ". Here is i: ", $(obj_str.i), ". Here is j: ", $(obj_str.j), ". Here is k: ", $(obj_str.k), ". Here is l: ", $(obj_str.l), ". Here is m: ", $(obj_str.m), ". Here is n: ", $(obj_str.n), ". Here is o: ", $(obj_str.o), ". Here is p: ", $(obj_str.p), ". Here is q: ", $(obj_str.q), ". Here is r: ", $(obj_str.r), ". Here is s: ", $(obj_str.s), ". Here is t: ", $(obj_str.t), ". Here is u: ", $(obj_str.u), ". Here is v: ", $(obj_str.v), ". Here is w: ", $(obj_str.w), ". Here is x: ", $(obj_str.x), ". Here is y: ", $(obj_str.y), ". Here is z: ", $(obj_str.z), ".") setup=(io = IOBuffer())

#==============================================================================#
# Write report.md
#==============================================================================#
@info "Writing report.md..."

labels = [
    "Small (2 vars, string return)",
    "Mostly-static (2 vars in text, string return)",
    "Many vars, int values (string return)",
    "Many vars, string values (string return)",
    "Many vars, int values (IO write)",
    "Many vars, string values (IO write)",
]

rows = [
    row(st1, mu1, ba1),
    row(st2, mu2, ba2),
    row(st3, mu3, ba3),
    row(st4, mu4, ba4),
    row(st5, mu5, ba5),
    row(st6, mu6, ba6),
]

open(joinpath(@__DIR__, "report.md"), "w") do io
    println(io, "# StringTemplates.jl Benchmark Report")
    println(io)
    vi = IOBuffer()
    versioninfo(vi)
    println(io, "Generated: $(Dates.now())")
    println(io)
    println(io, "```")
    print(io, String(take!(vi)))
    println(io, "```")
    println(io)

    # Time comparison table
    println(io, "## Time (minimum)")
    println(io)
    println(io, "| Benchmark | StringTemplates | Mustache | Base | vs Mustache | vs Base |")
    println(io, "|:----------|----------------:|---------:|-----:|------------:|--------:|")
    for (label, r) in zip(labels, rows)
        println(io, "| $label | $(r.time_st) | $(r.time_mu) | $(r.time_ba) | $(r.vs_mu_time) | $(r.vs_ba_time) |")
    end
    println(io)

    # Memory comparison table
    println(io, "## Memory (bytes and allocations)")
    println(io)
    println(io, "| Benchmark | StringTemplates | Mustache | Base | vs Mustache | vs Base |")
    println(io, "|:----------|----------------:|---------:|-----:|------------:|--------:|")
    for (label, r) in zip(labels, rows)
        println(io, "| $label | $(r.mem_st) | $(r.mem_mu) | $(r.mem_ba) | $(r.vs_mu_mem) | $(r.vs_ba_mem) |")
    end
end

@info "Wrote benchmarks/report.md"

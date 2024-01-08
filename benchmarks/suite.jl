import Pkg

Pkg.activate(@__DIR__)

using StringTemplates, Mustache, BenchmarkTools

obj = (; (Symbol(letter) => i for (i, letter) in enumerate('a':'z'))...)
obj2 = (; (Symbol(letter) => letter ^ i for (i, letter) in enumerate('a':'z'))...)

#-----------------------------------------------------------------------------# StringTemplates
t = template"Here is a: $a. Here is b: $b. Here is c: $c. Here is d: $d. Here is e: $e. Here is f: $f. Here is g: $g. Here is h: $h. Here is i: $i. Here is j: $j. Here is k: $k. Here is l: $l. Here is m: $m. Here is n: $n. Here is o: $o. Here is p: $p. Here is q: $q. Here is r: $r. Here is s: $s. Here is t: $t. Here is u: $u. Here is v: $v. Here is w: $w. Here is x: $x. Here is y: $y. Here is z: $z."

stringtemplate_benchmarks = [
    @benchmark StringTemplates.render($t, $obj)
    @benchmark StringTemplates.render($t, $obj2)
    @benchmark StringTemplates.render(io, $t, $obj) setup=(io = IOBuffer())
    @benchmark StringTemplates.render(io, $t, $obj2) setup=(io = IOBuffer())
]

#-----------------------------------------------------------------------------# Mustache
m = Mustache.mt"This is a: {{a}}. This is b: {{b}}. This is c: {{c}}. This is d: {{d}}. This is e: {{e}}. This is f: {{f}}. This is g: {{g}}. This is h: {{h}}. This is i: {{i}}. This is j: {{j}}. This is k: {{k}}. This is l: {{l}}. This is m: {{m}}. This is n: {{n}}. This is o: {{o}}. This is p: {{p}}. This is q: {{q}}. This is r: {{r}}. This is s: {{s}}. This is t: {{t}}. This is u: {{u}}. This is v: {{v}}. This is w: {{w}}. This is x: {{x}}. This is y: {{y}}. This is z: {{z}}."

mustache_benchmarks = [
    @benchmark Mustache.render($m, $(Dict(pairs(obj)...)))
    @benchmark Mustache.render($m, $(Dict(pairs(obj2)...)))
    @benchmark Mustache.render(io, $m, $(Dict(pairs(obj)...))) setup=(io = IOBuffer())
    @benchmark Mustache.render(io, $m, $(Dict(pairs(obj2)...))) setup=(io = IOBuffer())
]

#-----------------------------------------------------------------------------# Base
base_benchmarks = [
    @benchmark "Here is a: $(obj.a). Here is b: $(obj.b). Here is c: $(obj.c). Here is d: $(obj.d). Here is e: $(obj.e). Here is f: $(obj.f). Here is g: $(obj.g). Here is h: $(obj.h). Here is i: $(obj.i). Here is j: $(obj.j). Here is k: $(obj.k). Here is l: $(obj.l). Here is m: $(obj.m). Here is n: $(obj.n). Here is o: $(obj.o). Here is p: $(obj.p). Here is q: $(obj.q). Here is r: $(obj.r). Here is s: $(obj.s). Here is t: $(obj.t). Here is u: $(obj.u). Here is v: $(obj.v). Here is w: $(obj.w). Here is x: $(obj.x). Here is y: $(obj.y). Here is z: $(obj.z)."
    @benchmark "Here is a: $(obj2.a). Here is b: $(obj2.b). Here is c: $(obj2.c). Here is d: $(obj2.d). Here is e: $(obj2.e). Here is f: $(obj2.f). Here is g: $(obj2.g). Here is h: $(obj2.h). Here is i: $(obj2.i). Here is j: $(obj2.j). Here is k: $(obj2.k). Here is l: $(obj2.l). Here is m: $(obj2.m). Here is n: $(obj2.n). Here is o: $(obj2.o). Here is p: $(obj2.p). Here is q: $(obj2.q). Here is r: $(obj2.r). Here is s: $(obj2.s). Here is t: $(obj2.t). Here is u: $(obj2.u). Here is v: $(obj2.v). Here is w: $(obj2.w). Here is x: $(obj2.x). Here is y: $(obj2.y). Here is z: $(obj2.z)."
    @benchmark print(io, "Here is a: $(obj.a). Here is b: $(obj.b). Here is c: $(obj.c). Here is d: $(obj.d). Here is e: $(obj.e). Here is f: $(obj.f). Here is g: $(obj.g). Here is h: $(obj.h). Here is i: $(obj.i). Here is j: $(obj.j). Here is k: $(obj.k). Here is l: $(obj.l). Here is m: $(obj.m). Here is n: $(obj.n). Here is o: $(obj.o). Here is p: $(obj.p). Here is q: $(obj.q). Here is r: $(obj.r). Here is s: $(obj.s). Here is t: $(obj.t). Here is u: $(obj.u). Here is v: $(obj.v). Here is w: $(obj.w). Here is x: $(obj.x). Here is y: $(obj.y). Here is z: $(obj.z).") setup=(io = IOBuffer())
    @benchmark print(io, "Here is a: $(obj2.a). Here is b: $(obj2.b). Here is c: $(obj2.c). Here is d: $(obj2.d). Here is e: $(obj2.e). Here is f: $(obj2.f). Here is g: $(obj2.g). Here is h: $(obj2.h). Here is i: $(obj2.i). Here is j: $(obj2.j). Here is k: $(obj2.k). Here is l: $(obj2.l). Here is m: $(obj2.m). Here is n: $(obj2.n). Here is o: $(obj2.o). Here is p: $(obj2.p). Here is q: $(obj2.q). Here is r: $(obj2.r). Here is s: $(obj2.s). Here is t: $(obj2.t). Here is u: $(obj2.u). Here is v: $(obj2.v). Here is w: $(obj2.w). Here is x: $(obj2.x). Here is y: $(obj2.y). Here is z: $(obj2.z).") setup=(io = IOBuffer())
]

function results(i)
    r = ratio(minimum(mustache_benchmarks[i]), minimum(stringtemplate_benchmarks[i]))
    r2 = ratio(minimum(base_benchmarks[i]), minimum(stringtemplate_benchmarks[i]))
    println("#-----------------------------------------------------------------------------# Benchmark $i")

    println("In benchmark $i, StringTemplates is $(round(r.time, digits=2)) times faster than Mustache.")
    println("In benchmark $i, StringTemplates is $(round(r2.time, digits=2)) times faster than Base string interpolation.")
end

results(1)
results(2)
results(3)
results(4)

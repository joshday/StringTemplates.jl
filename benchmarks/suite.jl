import Pkg

Pkg.activate(@__DIR__)

using StringTemplates, Mustache, BenchmarkTools

s = '"' * join("Here is $x: {{$x}}. " for x in 'a':'z') * '"'

obj = (; (Symbol(letter) => i for (i, letter) in enumerate('a':'z'))...)

#-----------------------------------------------------------------------------# StringTemplates
t = template"Here is a: $a. Here is b: $b. Here is c: $c. Here is d: $d. Here is e: $e. Here is f: $f. Here is g: $g. Here is h: $h. Here is i: $i. Here is j: $j. Here is k: $k. Here is l: $l. Here is m: $m. Here is n: $n. Here is o: $o. Here is p: $p. Here is q: $q. Here is r: $r. Here is s: $s. Here is t: $t. Here is u: $u. Here is v: $v. Here is w: $w. Here is x: $x. Here is y: $y. Here is z: $z."

b1 = @benchmark StringTemplates.render($t, $obj)

#-----------------------------------------------------------------------------# Mustache
m = Mustache.mt"This is a: {{a}}. This is b: {{b}}. This is c: {{c}}. This is d: {{d}}. This is e: {{e}}. This is f: {{f}}. This is g: {{g}}. This is h: {{h}}. This is i: {{i}}. This is j: {{j}}. This is k: {{k}}. This is l: {{l}}. This is m: {{m}}. This is n: {{n}}. This is o: {{o}}. This is p: {{p}}. This is q: {{q}}. This is r: {{r}}. This is s: {{s}}. This is t: {{t}}. This is u: {{u}}. This is v: {{v}}. This is w: {{w}}. This is x: {{x}}. This is y: {{y}}. This is z: {{z}}."

b2 = @benchmark Mustache.render($m, $(Dict(pairs(obj)...)))

#-----------------------------------------------------------------------------# Base
b3 = @benchmark "Here is a: $(obj.a). Here is b: $(obj.b). Here is c: $(obj.c). Here is d: $(obj.d). Here is e: $(obj.e). Here is f: $(obj.f). Here is g: $(obj.g). Here is h: $(obj.h). Here is i: $(obj.i). Here is j: $(obj.j). Here is k: $(obj.k). Here is l: $(obj.l). Here is m: $(obj.m). Here is n: $(obj.n). Here is o: $(obj.o). Here is p: $(obj.p). Here is q: $(obj.q). Here is r: $(obj.r). Here is s: $(obj.s). Here is t: $(obj.t). Here is u: $(obj.u). Here is v: $(obj.v). Here is w: $(obj.w). Here is x: $(obj.x). Here is y: $(obj.y). Here is z: $(obj.z)."

#-----------------------------------------------------------------------------# Analysis
println("#-------------------------------------------------------------------------# StringTemplates")
display(b1)

println("\n\n")

println("#-------------------------------------------------------------------------# Mustache")
display(b2)

println("\n\n")

println("#-------------------------------------------------------------------------# Base")
display(b3)

println("\n\n")

println("#-------------------------------------------------------------------------# Median Ratio")
r = ratio(median(b2), median(b1))
r2 = ratio(median(b3), median(b1))

@info "In this benchmark, StringTemplates is $(round(r.time, digits=2)) times faster than Mustache."
@info "In this benchmark, StringTemplates is $(round(r2.time, digits=2)) times faster than Base string interpolation."

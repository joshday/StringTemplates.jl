import Pkg

Pkg.activate(@__DIR__)

using StringInterp, Mustache, BenchmarkTools


t = @template """
    Here is a: $a.
    Here is b: $b.
    Here is c: $c.
    Here is d: $d.
    Here is e: $e.
    Here is f: $f.
    Here is g: $g.
    Here is h: $h.
    Here is i: $i.
    Here is j: $j.
    Here is k: $k.
    Here is l: $l.
    Here is m: $m.
    Here is n: $n.
    Here is o: $o.
    Here is p: $p.
    Here is q: $q.
    Here is r: $r.
    Here is s: $s.
    Here is t: $t.
    Here is u: $u.
    Here is v: $v.
    Here is w: $w.
    Here is x: $x.
    Here is y: $y.
    Here is z: $z.
    """

m = mt"""
    Here is a: {{a}}.
    Here is b: {{b}}.
    Here is c: {{c}}.
    Here is d: {{d}}.
    Here is e: {{e}}.
    Here is f: {{f}}.
    Here is g: {{g}}.
    Here is h: {{h}}.
    Here is i: {{i}}.
    Here is j: {{j}}.
    Here is k: {{k}}.
    Here is l: {{l}}.
    Here is m: {{m}}.
    Here is n: {{n}}.
    Here is o: {{o}}.
    Here is p: {{p}}.
    Here is q: {{q}}.
    Here is r: {{r}}.
    Here is s: {{s}}.
    Here is t: {{t}}.
    Here is u: {{u}}.
    Here is v: {{v}}.
    Here is w: {{w}}.
    Here is x: {{x}}.
    Here is y: {{y}}.
    Here is z: {{z}}.
    """

obj = (; (Symbol(letter) => i for (i, letter) in enumerate('a':'z'))...)

b1 = @benchmark StringInterp.render($t, $obj)

b2 = @benchmark Mustache.render($m, $(Dict(pairs(obj)...)))

b3 = @benchmark let
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
    g = 7
    h = 8
    i = 9
    j = 10
    k = 11
    l = 12
    m = 13
    n = 14
    o = 15
    p = 16
    q = 17
    r = 18
    s = 19
    t = 20
    u = 21
    v = 22
    w = 23
    x = 24
    y = 25
    z = 26
    """
    Here is a: $a.
    Here is b: $b.
    Here is c: $c.
    Here is d: $d.
    Here is e: $e.
    Here is f: $f.
    Here is g: $g.
    Here is h: $h.
    Here is i: $i.
    Here is j: $j.
    Here is k: $k.
    Here is l: $l.
    Here is m: $m.
    Here is n: $n.
    Here is o: $o.
    Here is p: $p.
    Here is q: $q.
    Here is r: $r.
    Here is s: $s.
    Here is t: $t.
    Here is u: $u.
    Here is v: $v.
    Here is w: $w.
    Here is x: $x.
    Here is y: $y.
    Here is z: $z.
    """
end

println("#-------------------------------------------------------------------------# StringInterp")
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
r2 = ratio(median(b2), median(b3))

@info "In this benchmark, StringInterp is $(round(r.time, digits=2)) times faster than Mustache."
@info "In this benchmark, StringInterp is $(round(r2.time, digits=2)) times faster than Base string interpolation."

function check_empty(g::AbstractGraph)
    if nv(g) != 0
        throw(ArgumentError("The graph should be empty."))
    end
end

in_domain(b::Bijection, x) = x in b.domain
in_range(b::Bijection, y) = y in b.range

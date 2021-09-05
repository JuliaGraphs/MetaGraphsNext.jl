const MetaUndirectedGraph = MetaGraph{<:Any,<:Any,<:SimpleGraph}

SimpleGraph(g::MetaUndirectedGraph) = g.graph

is_directed(::Type{<:MetaUndirectedGraph}) = false

function arrange(g::MetaUndirectedGraph, label_1, label_2)
    vprops = g.vprops
    arrange(g::MetaUndirectedGraph, label_1, label_2, vprops[label_1], vprops[label_2])
end

function arrange(g::MetaUndirectedGraph, label_1, label_2, u, v)
    if u > v
        (label_2, label_1)
    else
        (label_1, label_2)
    end
end

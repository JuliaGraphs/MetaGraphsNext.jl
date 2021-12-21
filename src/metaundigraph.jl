"""
    MetaUndirectedGraph

A `MetaGraph` whose underlying graph is of type `Graphs.SimpleGraph`.
"""
const MetaUndirectedGraph = MetaGraph{<:Any,<:Any,<:SimpleGraph}

Graphs.SimpleGraph(g::MetaUndirectedGraph) = g.graph

Graphs.is_directed(::Type{<:MetaUndirectedGraph}) = false
Graphs.is_directed(::MetaUndirectedGraph) = false

function arrange(
    ::MetaUndirectedGraph{<:Any,Label},
    label_1::Label,
    label_2::Label,
    v1::Integer,
    v2::Integer,
) where {T,Label}
    if v1 < v2
        return (label_1, label_2)
    else
        return (label_2, label_1)
    end
end

function arrange(
    g::MetaUndirectedGraph{<:Any,Label}, label_1::Label, label_2::Label
) where {Label}
    v1, v2 = code_for(g, label_1), code_for(g, label_2)
    return arrange(g, label_1, label_2, v1, v2)
end

"""
    MetaDiGraph

A `MetaGraph` whose underlying graph is of type `Graphs.SimpleDiGraph`.
"""
const MetaDiGraph = MetaGraph{<:Any,<:Any,<:SimpleDiGraph}

Graphs.SimpleDiGraph(g::MetaDiGraph) = g.graph

Graphs.is_directed(::Type{<:MetaDiGraph}) = true
Graphs.is_directed(::MetaDiGraph) = true

function arrange(
    ::MetaDiGraph{<:Any,Label}, label_1::Label, label_2::Label, args...
) where {Label}
    return label_1, label_2
end

"""
    MetaDiGraph

A `MetaGraph` whose underlying graph is of type `Graphs.SimpleDiGraph`.
"""
const MetaDiGraph = MetaGraph{<:Any,<:Any,<:SimpleDiGraph}

function Graphs.SimpleDiGraph(meta_graph::MetaDiGraph)
    return meta_graph.graph
end

function Graphs.is_directed(::Type{<:MetaDiGraph})
    return true
end
function Graphs.is_directed(::MetaDiGraph)
    return true
end

function arrange(::MetaDiGraph, label_1, label_2, _...)
    return label_1, label_2
end

"""
    MetaDiGraph

A `MetaGraph` whose underlying graph is of type `Graphs.SimpleDiGraph`.
"""
const MetaDiGraph = MetaGraph{<:Any, <:Any, <:SimpleDiGraph}

function Graphs.SimpleDiGraph(meta_graph::MetaDiGraph)
    meta_graph.graph
end

function Graphs.is_directed(::Type{<:MetaDiGraph})
    true
end
function Graphs.is_directed(::MetaDiGraph)
    true
end

function arrange(
    ::MetaDiGraph,
    label_1,
    label_2,
    _...,
)
    label_1, label_2
end

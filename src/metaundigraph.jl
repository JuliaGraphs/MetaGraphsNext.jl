"""
    MetaUndirectedGraph

A `MetaGraph` whose underlying graph is of type `Graphs.SimpleGraph`.
"""
const MetaUndirectedGraph = MetaGraph{<:Any, <:Any, <:SimpleGraph}

Graphs.SimpleGraph(meta_graph::MetaUndirectedGraph) = meta_graph.graph

Graphs.is_directed(::Type{<:MetaUndirectedGraph}) = false
Graphs.is_directed(::MetaUndirectedGraph) = false

function arrange(
    ::MetaUndirectedGraph,
    label_1,
    label_2,
    code_1,
    code_2,
)
    if code_1 < code_2
        (label_1, label_2)
    else
        (label_2, label_1)
    end
end

function arrange(
    meta_graph::MetaUndirectedGraph,
    label_1,
    label_2,
)
    arrange(meta_graph, label_1, label_2, code_for(meta_graph, label_1), code_for(meta_graph, label_2))
end

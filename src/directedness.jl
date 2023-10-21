function Graphs.is_directed(::MetaGraph{Code,Graph}) where {Code,Graph<:AbstractGraph}
    return is_directed(Graph)
end

function Graphs.is_directed(
    ::Type{<:MetaGraph{Code,Graph}}
) where {Code,Graph<:AbstractGraph}
    return is_directed(Graph)
end

"""
    arrange(graph, label_1, label_2)

Sort two vertex labels in a default order (useful to uniquely express undirected edges).
For undirected graphs, the default order is based on the labels themselves
to be robust to vertex re-coding, so the labels need to support `<`.
"""
function arrange end

@traitfn function arrange(
    ::MG, label_1, label_2, _drop...
) where {MG <: MetaGraph; IsDirected{MG}}
    return label_1, label_2
end

@traitfn function arrange(
    ::MG, label_1, label_2, code_1, code_2
) where {MG <: MetaGraph; !IsDirected{MG}}
    if label_1 < label_2
        (label_1, label_2)
    else
        (label_2, label_1)
    end
end

@traitfn function arrange(
    meta_graph::MG, label_1, label_2
) where {MG <: MetaGraph; !IsDirected{MG}}
    return arrange(
        meta_graph,
        label_1,
        label_2,
        code_for(meta_graph, label_1),
        code_for(meta_graph, label_2),
    )
end

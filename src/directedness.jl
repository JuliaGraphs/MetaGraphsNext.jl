"""
    arrange(graph, label_1, label_2)

Sort two vertex labels in a default order (useful to uniquely express undirected edges).
"""
function arrange end

@traitfn function arrange(
    ::AG::IsDirected, label_1, label_2, _drop...
) where {T,AG<:AbstractGraph{T}}
    return label_1, label_2
end

@traitfn function arrange(
    ::AG::(!IsDirected), label_1, label_2, code_1, code_2
) where {T,AG<:AbstractGraph{T}}
    if code_1 < code_2
        (label_1, label_2)
    else
        (label_2, label_1)
    end
end

@traitfn function arrange(
    meta_graph::AG::(!IsDirected), label_1, label_2
) where {T,AG<:AbstractGraph{T}}
    return arrange(
        meta_graph,
        label_1,
        label_2,
        code_for(meta_graph, label_1),
        code_for(meta_graph, label_2),
    )
end

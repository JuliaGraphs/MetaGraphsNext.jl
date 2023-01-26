@traitfn Graphs.SimpleGraph(meta_graph::MetaGraph::(!IsDirected)) = meta_graph.graph

@traitfn function arrange(::AG::(!IsDirected), label_1, label_2, code_1, code_2) where {T, AG <: AbstractGraph{T}}
    if code_1 < code_2
        (label_1, label_2)
    else
        (label_2, label_1)
    end
end

@traitfn function arrange(meta_graph::AG::(!IsDirected), label_1, label_2) where {T, AG <: AbstractGraph{T}}
    arrange(meta_graph, label_1, label_2, code_for(meta_graph, label_1), code_for(meta_graph, label_2))
end

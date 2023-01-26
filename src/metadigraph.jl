@traitfn Graphs.SimpleDiGraph(meta_graph::MetaGraph::(IsDirected)) = meta_graph.graph

@traitfn function arrange(::AG::IsDirected, label_1, label_2, _drop...) where {T, AG <: AbstractGraph{T}}
    label_1, label_2
end

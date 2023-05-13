struct LabeledMetaGraph{T,G<:AbstractGraph{T},L,UMG<:AbstractUnlabeledMetaGraph{T,G}} <:
       AbstractLabeledMetaGraph{T,G,L}
    unlabeled_metagraph::UMG
    labels::Bijection{T,L}
end

function LabeledMetaGraph(
    unlabeled_metagraph::UMG, label_type::Type{L}
) where {T,G,UMG<:AbstractUnlabeledMetaGraph{T,G},L}
    check_empty(unlabeled_metagraph)
    labels = Bijection{T,L}()
    return LabeledMetaGraph{T,G,L,UMG}(unlabeled_metagraph, labels)
end

function LabeledMetaGraph(
    graph::G,
    label_type::Type{L};
    vertex_data_type::Type{VD}=Nothing,
    edge_data_type::Type{ED}=Nothing,
    graph_data::GD=nothing,
) where {T,G<:AbstractGraph{T},L,VD,ED,GD}
    umg = UnlabeledMetaGraph(graph; vertex_data_type, edge_data_type, graph_data)
    return LabeledMetaGraph(umg, label_type)
end

get_metagraph(lmg::LabeledMetaGraph) = lmg.unlabeled_metagraph

for op in (:get_graph, :get_data, :set_data!)
    @eval $op(lmg::LabeledMetaGraph, args...) = $op(get_metagraph(lmg), args...)
end

has_label(lmg::LabeledMetaGraph, li) = in_range(lmg.labels, li)
get_vertex(lmg::LabeledMetaGraph, li) = inverse(lmg.labels, li)
get_label(lmg::LabeledMetaGraph, i) = lmg.labels[i]
set_label!(lmg::LabeledMetaGraph, i, li) = lmg.labels[i] = li

function Graphs.add_vertex!(lmg::LabeledMetaGraph, li, data)
    if !has_label(lmg, li)
        nv_prev = nv(lmg)
        i = nv_prev + 1
        lmg.labels[i] = li
        add_vertex!(get_metagraph(lmg), data)
        if nv(lmg) == nv_prev
            delete!(lmg.labels, i)
            return false
        else
            return true
        end
    else
        return false
    end
end

function Graphs.add_edge!(lmg::LabeledMetaGraph, li, lj, data)
    if has_label(lmg, li) && has_label(lmg, lj)
        i, j = get_vertex(lmg, li), get_vertex(lmg, lj)
        return add_edge!(get_metagraph(lmg), i, j, data)
    else
        return false
    end
end

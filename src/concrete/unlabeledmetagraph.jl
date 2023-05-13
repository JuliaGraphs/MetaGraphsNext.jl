struct UnlabeledMetaGraph{T,G<:AbstractGraph{T},VD,ED,GD} <: AbstractUnlabeledMetaGraph{T,G}
    graph::G
    vertex_data::Dict{T,VD}
    edge_data::Dict{Tuple{T,T},ED}
    graph_data::Base.RefValue{GD}
end

function UnlabeledMetaGraph(
    graph::G;
    vertex_data_type::Type{VD}=Nothing,
    edge_data_type::Type{ED}=Nothing,
    graph_data::GD=nothing,
) where {T,G<:AbstractGraph{T},VD,ED,GD}
    check_empty(graph)
    vertex_data = Dict{T,VD}()
    edge_data = Dict{Tuple{T,T},ED}()
    return UnlabeledMetaGraph{T,G,VD,ED,GD}(graph, vertex_data, edge_data, Ref(graph_data))
end

get_graph(umg::UnlabeledMetaGraph) = umg.graph

function arrange(umg::UnlabeledMetaGraph, i::Integer, j::Integer)
    if is_directed(umg)
        return i, j
    else
        return min(i, j), max(i, j)
    end
end

get_data(umg::UnlabeledMetaGraph) = umg.graph_data
get_data(umg::UnlabeledMetaGraph, i::Integer) = umg.vertex_data[i]

function get_data(umg::UnlabeledMetaGraph, i::Integer, j::Integer)
    return umg.edge_data[arrange(umg, i, j)]
end

function set_data!(umg::UnlabeledMetaGraph, data)
    umg.graph_data[] = data
    return true
end

function set_data!(umg::UnlabeledMetaGraph, i::Integer, data)
    if has_vertex(umg, i)
        umg.vertex_data[i] = data
        return true
    else
        return false
    end
end

function set_data!(umg::UnlabeledMetaGraph, i::Integer, j::Integer, data)
    if has_edge(umg, i, j)
        umg.edge_data[arrange(umg, i, j)] = data
        return true
    else
        return false
    end
end

function Graphs.add_vertex!(umg::UnlabeledMetaGraph, data)
    nv_prev = nv(umg)
    i = nv_prev + 1
    umg.vertex_data[i] = data
    add_vertex!(get_graph(umg))
    if nv(umg) == nv_prev  # undo
        delete!(umg.vertex_data, i)
        return false
    else
        return true
    end
end

function Graphs.add_edge!(umg::UnlabeledMetaGraph, i, j, data)
    ne_prev = ne(umg)
    umg.edge_data[arrange(umg, i, j)] = data
    add_edge!(get_graph(umg), i, j)
    if ne(umg) == ne_prev  # undo
        delete!(umg.edge_data, arrange(umg, i, j))
        return false
    else
        return true
    end
end

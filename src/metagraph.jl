struct MetaGraph{T,G<:AbstractGraph{T},L,VD,ED,GD} <: AbstractMetaGraph{T,G,L,VD,ED,GD}
    graph::Graph
    labels::Bijection{T,L}
    vertex_data::Dict{T,VD}
    edge_data::Dict{Tuple{T,T},ED}
    graph_data::GD
end

function MetaGraph(
    graph::G, ::Type{L}=T, ::Type{VD}=Nothing, ::Type{ED}=Nothing, graph_data::GD=nothing
) where {T,G<:AbstractGraph{T},L,VD,ED,GD}
    if nv(graph) != 0
        throw(ArgumentError("For this constructor, the underlying graph should be empty."))
    end
    labels = Bijection{T,L}()
    vertex_data = Dict{T,VD}()
    edge_data = Dict{Tuple{T,T},ED}()
    return MetaGraph{T,G,L,VD,ED,GD}(graph, labels, vertex_data, edge_data, graph_data)
end

function MetaGraph(
    graph; label_type, vertex_data_type=Nothing, edge_data_type=Nothing, graph_data=nothing
)
    return MetaGraph(graph, label_type, vertex_data_type, edge_data_type, graph_data)
end

function Base.show(io::IO, mg::MetaGraph{T,G,L,VD,ED,GD}) where {T,G,L,VD,ED,GD}
    print(
        io,
        "MetaGraph based on a $G with $(nv(mg)) vertices and $(ne(mg)) edges, vertex labels of type $L, vertex metadata of type $VD, edge metadata of type $ED, graph metadata of type $GD.",
    )
    return nothing
end

Base.copy(mg::MetaGraph) = deepcopy(mg)

in_domain(b::Bijection, x) = x in b.domain
in_range(b::Bijection, y) = y in b.range

get_graph(mg::MetaGraph) = mg.graph
get_label(mg::MetaGraph, v) = mg.label[v]
get_vertex(mg::MetaGraph, l) = inverse(mg.labels, l)
has_label(mg::MetaGraph, l) = in_range(mg.labels, l)

function arrange(mg::MetaGraph, i::Integer, j::Integer)
    if is_directed(mg)
        return i, j
    else
        return min(i, j), max(i, j)
    end
end

get_data(mg::MetaGraph) = mg.graph_data
get_data(mg::MetaGraph, i::Integer) = mg.vertex_data[i]
get_data(mg::MetaGraph, i::Integer, j::Integer) = mg.edge_data[arrange(mg, i, j)]

function set_data!(mg::MetaGraph, i::Integer, data)
    if has_vertex(mg, i)
        mg.vertex_data[i] = data
        return true
    else
        return false
    end
end

function set_data!(mg::MetaGraph, i::Integer, j::Integer, data)
    if has_edge(mg, i, j)
        mg.edge_data[arrange(mg, i, j)] = data
        return true
    else
        return false
    end
end

function add_vertex!_labels(mg::MetaGraph, l, data)
    nv_prev = nv(mg)
    i = nv_prev + 1
    mg.labels[i] = l
    mg.vertex_data[i] = data
    add_vertex!(get_graph(mg))
    if nv(mg) == nv_prev  # undo
        delete!(mg.labels, i)
        delete!(mg.vertex_data, l)
        return false
    else
        return true
    end
end

function Graphs.add_vertex!(mg::MetaGraph, data)
    return add_vertex!_labels(mg, nv(mg) + 1, data)
end

function Graphs.add_edge!(mg::MetaGraph, i, j, data)
    ne_prev = ne(mg)
    mg.edge_data[arrange(mg, i, j)] = data
    add_edge!(get_graph(mg), i, j)
    if ne(mg) == ne_prev  # undo
        delete!(mg.edge_data, arrange(mg, i, j))
        return false
    else
        return true
    end
end

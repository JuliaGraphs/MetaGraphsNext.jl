"""
    MetaGraph{T<:Integer,Label,Graph,VertexData,EdgeData,GraphData,WeightFunction,U<:Real} <: AbstractGraph{T}

A graph type with custom vertex labels containing vertex-, edge- and graph-level metadata.

Vertex labels have type `Label`, while vertex (resp. edge, resp. graph) metadata has type `VertexData` (resp. `EdgeData`, resp. `GraphData`).
It is recommended not to set `Label` to an integer type, so as to avoid confusion between vertex labels and vertex codes (which have type `T<:Integer`).

# Fields
- `g::Graph`: underlying, data-less graph with vertex indices of type `T`
- `vertex_labels::Dict{T,Label}`: dictionary mapping vertex codes to vertex labels
- `vertex_properties::Dict{Label,Tuple{T,VertexData}}`: dictionary mapping vertex labels to vertex codes & data
- `edge_data::Dict{Tuple{Label,Label},EdgeData}`: dictionary mapping edge labels such as `(label_u, label_v)` to edge metadata
- `graph_data::GraphData`: graph metadata
- `weight_function::WeightFunction`: function defining edge weight from edge metadata
- `default_weight::U`: default weight for the edges
"""
struct MetaGraph{
    T<:Integer,Label,Graph,VertexData,EdgeData,GraphData,WeightFunction,U<:Real
} <: AbstractGraph{T}
    graph::Graph
    vertex_labels::Dict{T,Label}
    vertex_properties::Dict{Label,Tuple{T,VertexData}}
    edge_data::Dict{Tuple{Label,Label},EdgeData}
    graph_data::GraphData
    weight_function::WeightFunction
    default_weight::U
end

"""
    MetaGraph(
        g;
        Label = Symbol,
        VertexData = Nothing,
        EdgeData = Nothing,
        graph_data = nothing,
        weight_function = edge_data -> 1.0,
        default_weight = 1.0
    )

Construct an empty `MetaGraph` with the given metadata types and weights.
"""
function MetaGraph(
    graph::AbstractGraph{T};
    Label=Symbol,
    VertexData=Nothing,
    EdgeData=Nothing,
    graph_data=nothing,
    weight_function=edata -> 1.0,
    default_weight=1.0,
) where {T}
    if Label <: Integer
        @warn "Constructing a MetaGraph with integer labels is not advised."
    elseif nv(graph) > 0
        @warn "Constructing a MetaGraph with a nonempty underlying graph is not advised."
    end
    return MetaGraph(
        graph,
        Dict{T,Label}(),
        Dict{Label,Tuple{T,VertexData}}(),
        Dict{Tuple{Label,Label},EdgeData}(),
        graph_data,
        weight_function,
        default_weight,
    )
end

"""
    arrange(g, label_1, label_2)

Sort two vertex labels in a default order (useful to uniquely express undirected edges).
"""
function arrange end

function Base.zero(
    g::MetaGraph{T,Label,Graph,VertexData,EdgeData}
) where {T,Label,Graph,VertexData,EdgeData}
    return MetaGraph(
        Graph();
        Label=Label,
        VertexData=VertexData,
        EdgeData=EdgeData,
        graph_data=g.graph_data,
        weight_function=g.weight_function,
        default_weight=g.default_weight,
    )
end

Base.:(==)(x::MetaGraph, y::MetaGraph) = x.graph == y.graph

Base.copy(g::MetaGraph) = deepcopy(g)

function Base.show(
    io::IO, g::MetaGraph{<:Any,Label,<:Any,VertexData,EdgeData}
) where {Label,VertexData,EdgeData}
    return print(
        io,
        "Meta graph based on a $(g.graph) with vertex labels of type $Label, vertex metadata of type $VertexData, edge metadata of type $EdgeData, graph metadata given by $(repr(g.graph_data)), and default weight $(g.default_weight)",
    )
end

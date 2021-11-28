"""
    MetaGraph{T<:Integer,Label,Graph,VertexMeta,EdgeMeta,GraphMeta,WeightFunction,U<:Real} <: AbstractGraph{T}

A graph type with custom vertex labels containing vertex-, edge- and graph-level metadata.

Vertex labels have type `Label`, while vertex (resp. edge, resp. graph) metadata has type `VertexMeta` (resp. `EdgeMeta`, resp. `GraphMeta`).
It is recommended not to set `Label` to an integer type, so as to avoid confusion between vertex labels and vertex codes (which have type `T<:Integer`).

# Fields
- `g::Graph`: underlying, data-less graph with vertex indices of type `T`
- `labels::Dict{T,Label}`: dictionary mapping vertex codes to vertex labels
- `vcodes::Dict{Label,T}`: dictionary mapping vertex labels to vertex codes
- `vprops::Dict{Label,VertexMeta}`: dictionary mapping vertex labels to vertex metadata
- `eprops::Dict{Tuple{Label,Label},EdgeMeta}`: dictionary mapping edge labels such as `(label_u, label_v)` to edge metadata
- `gprops::GraphMeta`: graph metadata
- `weightfunction::WeightFunction`: function defining edge weight from edge metadata
- `defaultweight::U`: default weight for the edges
"""
struct MetaGraph{
    T<:Integer,Label,Graph,VertexMeta,EdgeMeta,GraphMeta,WeightFunction,U<:Real
} <: AbstractGraph{T}
    graph::Graph
    labels::Dict{T,Label}
    vcodes::Dict{Label,T}
    vprops::Dict{Label,VertexMeta}
    eprops::Dict{Tuple{Label,Label},EdgeMeta}
    gprops::GraphMeta
    weightfunction::WeightFunction
    defaultweight::U
end

"""
    MetaGraph(
        g;
        Label = Symbol,
        VertexMeta = Nothing,
        EdgeMeta = Nothing,
        gprops = nothing,
        weightfunction = eprops -> 1.0,
        defaultweight = 1.0
    )

Construct an empty `MetaGraph` with the given metadata types and weights.
"""
function MetaGraph(
    g::AbstractGraph{T};
    Label=Symbol,
    VertexMeta=Nothing,
    EdgeMeta=Nothing,
    gprops=nothing,
    weightfunction=eprops -> 1.0,
    defaultweight=1.0,
) where {T}
    if Label <: Integer
        @warn "Constructing a MetaGraph with integer labels is not advised."
    end
    return MetaGraph(
        g,
        Dict{T,Label}(),
        Dict{Label,T}(),
        Dict{Label,VertexMeta}(),
        Dict{Tuple{Label,Label},EdgeMeta}(),
        gprops,
        weightfunction,
        defaultweight,
    )
end

"""
    arrange(g, label_1, label_2)

Sort two vertex labels in a default order (useful to uniquely express undirected edges).
"""
function arrange end

function Base.zero(
    g::MetaGraph{T,Label,Graph,VertexMeta,EdgeMeta,GraphMeta}
) where {T,Label,Graph,VertexMeta,EdgeMeta,GraphMeta}
    return MetaGraph(
        Graph();
        Label=Label,
        VertexMeta=VertexMeta,
        EdgeMeta=EdgeMeta,
        gprops=g.gprops,
        weightfunction=g.weightfunction,
        defaultweight=g.defaultweight,
    )
end

Base.:(==)(x::MetaGraph, y::MetaGraph) = x.graph == y.graph

Base.copy(g::MetaGraph) = deepcopy(g)

function Base.show(
    io::IO, g::MetaGraph{<:Any,Label,<:Any,VertexMeta,EdgeMeta}
) where {Label,VertexMeta,EdgeMeta}
    return print(
        io,
        "Meta graph based on a $(g.graph) with vertex labels of type $Label, vertex metadata of type $VertexMeta, edge metadata of type $EdgeMeta, graph metadata given by $(repr(g.gprops)), and default weight $(g.defaultweight)",
    )
end

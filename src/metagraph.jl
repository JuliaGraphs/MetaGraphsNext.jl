"""
    MetaGraph{T,Label,Graph,VertexMeta,EdgeMeta,GraphMeta,WeightFunction,U} <: AbstractGraph{T}

A graph type with custom vertex labels containing vertex-, edge- and graph-level metadata.

Vertex labels have type `Label`, while vertex (resp. edge, resp. graph) metadata has type `VertexMeta` (resp. `EdgeMeta`, resp. `GraphMeta`).
It is recommended not to set `Label` to `Int` to avoid confusion between vertex labels and vertex codes (which have type `T <: Integer`).

# Fields
- `g::Graph`: underlying, data-less graph with vertex indices of type `T`
- `vprops::Dict{Label,Tuple{T,VertexMeta}}`: dictionary mapping vertex labels to vertex codes and metadata
- `eprops::Dict{Tuple{Label,Label},EdgeMeta}`: dictionary mapping edge labels such as `(label_u, label_v)` to edge metadata
- `gprops::GraphMeta`: graph metadata
- `weightfunction::WeightFunction`: function defining edge weight from edge metadata
- `defaultweight::U`: default weight for the edges
- `metaindex::Dict{T,Label}`: dictionary mapping vertex codes to vertex labels
"""
struct MetaGraph{
    T<:Integer,
    Label,
    Graph,
    VertexMeta,
    EdgeMeta,
    GraphMeta,
    WeightFunction,
    U<:Real,
} <: AbstractGraph{T}
    graph::Graph
    vprops::Dict{Label,Tuple{T,VertexMeta}}
    eprops::Dict{Tuple{Label,Label},EdgeMeta}
    gprops::GraphMeta
    weightfunction::WeightFunction
    defaultweight::U
    metaindex::Dict{T,Label}
end

"""
    MetaGraph(g;
        Label = Symbol,
        VertexMeta = nothing,
        EdgeMeta = nothing,
        gprops = nothing,
        weightfunction = eprops -> 1.0,
        defaultweight = 1.0
    )
"""
function MetaGraph(
    g::AbstractGraph{T};
    Label = Symbol,
    VertexMeta = Nothing,
    EdgeMeta = Nothing,
    gprops = nothing,
    weightfunction = eprops -> 1.0,
    defaultweight = 1.0,
) where {Vertex,T}
    MetaGraph(
        g,
        Dict{Label,Tuple{T,VertexMeta}}(),
        Dict{Tuple{Label,Label},EdgeMeta}(),
        gprops,
        weightfunction,
        defaultweight,
        Dict{T,Label}(),
    )
end

zero(
    g::MetaGraph{T,Label,Graph,VertexMeta,EdgeMeta,GraphMeta},
) where {T,Label,Graph,VertexMeta,EdgeMeta,GraphMeta} = MetaGraph(
    Graph();
    Label = Label,
    VertexMeta = VertexMeta,
    EdgeMeta = EdgeMeta,
    gprops = g.gprops,
    weightfunction = g.weightfunction,
    defaultweight = g.defaultweight,
)

==(x::MetaGraph, y::MetaGraph) = x.graph == y.graph

copy(g::T) where {T<:MetaGraph} = deepcopy(g)

function show(
    io::IO,
    g::MetaGraph{<:Any,Label,<:Any,VertexMeta,EdgeMeta},
) where {Label,VertexMeta,EdgeMeta}
    print(
        io,
        "Meta graph based on a $(g.graph) with vertices indexed by $Label(s), $VertexMeta(s) vertex metadata, $EdgeMeta(s) edge metadata, $(repr(g.gprops)) as graph metadata, and default weight $(g.defaultweight)",
    )
end
